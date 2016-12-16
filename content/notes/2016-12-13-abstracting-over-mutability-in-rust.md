---
kind: article
created_at: 2016-12-13 20:29:07 +0000
title: "Abstracting over mutability in Rust"
tags:
  - software
  - rust
---

It is common to see the statement that "[Rust][] cannot abstract over mutability". Indeed,
many functions in the standard library have an immutable and a mutable variant, e.g.
[RefCell::borrow()][borrow] and [RefCell::borrow_mut()][borrow]. However, in some cases,
such as when wrapping another data structure, abstraction over mutability is possible.
In this note I will show how.

[rust]: https://rust-lang.org
[borrow]: https://doc.rust-lang.org/stable/core/cell/struct.RefCell.html#method.borrow
[borrow_mut]: https://doc.rust-lang.org/stable/core/cell/struct.RefCell.html#method.borrow_mut

* toc
{:toc}

# Motivation

I am writing a networking stack. An efficient networking stack would represent packets as
octet buffers, avoiding per-packet memory copies as much as possible. However, directly accessing
octets by their index is inconvenient and error-prone; so a networking stack would first wrap
the octet buffer in a newtype (a struct with a single field whose purpose is to provide
a different interface to the same underlying representation) that provides accessors.

Let's take an [UDP packet][udpheader] as an example, and write such a newtype:

[udpheader]: https://en.wikipedia.org/wiki/User_Datagram_Protocol#Packet_structure

<% highlight_code 'rust' do %>
extern crate byteorder;
use byteorder::{ByteEndian, NetworkEndian};

pub struct UdpPacket<'a> {
    pub buffer: &'a [u8]
}

impl<'a> UdpPacket<'a> {
    pub fn src_port(&self) -> u16 {
        NetworkEndian::read_u16(&self.buffer[0..2])
    }

    // etc...
}
<% end %>

This works just fine. Now let's try and add a mutator function:

<% highlight_code 'rust' do %>
impl<'a> UdpPacket<'a> {
    pub fn set_src_port(&mut self, value: u16) {
        NetworkEndian::write_u16(&mut self.buffer[0..2], value)
    }
}
<% end %>

This, of course, doesn't work, because `self.buffer` is not a mutable pointer:

<% highlight_code 'text' do %>
error: cannot borrow immutable borrowed content `*self.buffer` as mutable
  --> src/main.rs:22:39
   |
22 |         NetworkEndian::write_u16(&mut self.buffer[0..2], value)
   |                                       ^^^^^^^^^^^
<% end %>

# Adding genericism

Clearly, `UdpPacket` cannot store a single kind of pointer. Since there's no way to parameterize
just the mutability bit of a pointer, we can parameterize it over any type, and then add
implementations for immutable and mutable pointers:

<% highlight_code 'rust' do %>
pub struct UdpPacket<T> {
    pub buffer: T
}

impl<'a> UdpPacket<&'a [u8]> {
    pub fn src_port(&self) -> u16 {
        NetworkEndian::read_u16(&self.buffer[0..2])
    }
}

impl<'a> UdpPacket<&'a mut [u8]> {
    pub fn set_src_port(&mut self, value: u16) {
        NetworkEndian::write_u16(&mut self.buffer[0..2], value)
    }
}
<% end %>

This solution is a bit odd---after all, the `UdpPacket` structure can now be created, if not used,
with any type at all, not just octet buffers---but there's no real harm to it. What is problematic
though is that the accessors cannot be used on a packet wrapping a mutable buffer:

<% highlight_code 'text' do %>
error: no method named `src_port` found for type `UdpPacket<&mut [u8; 128]>`
       in the current scope
  --> src/main.rs:23:27
   |
22 |     let packet = UdpPacket { buffer: &mut buffer };
23 |     println!("{}", packet.src_port())
   |                           ^^^^^^^^
<% end %>

There are several reasons to want to interleave reads and writes to a packet:

* Computing a checksum: checksumming an IP, TCP or UDP packet requires first filling
  in the individual header fields as well as (for TCP and UDP) payload in the packet,
  then reading the underlying storage, then writing the checksum.

* Buffer reuse: a memory-constrained device may not have space for more than one
  1536-octet buffer, and so it could reuse the buffer by swapping the source and
  destination fields in various headers.

* Fields without a fixed location: many common protocols, such as ARP, IPv4 and IPv6,
  include optional and variable-sized fields, and so the place to write a field
  depends on the data elsewhere in the packet.

* Debugging: a packet may be pretty-printed after or while filling it in.

# Using traits for abstraction

Fortunately, Rust already provides tools for abstracting over mutability: the little-known
and rarely used [AsRef][] and [AsMut][] traits. Unlike with bare impls, functions defined
in an `impl<T: AsMut<U>>` will work with a `&U` just as well as `&mut U`.

[asref]: https://doc.rust-lang.org/stable/core/convert/trait.AsRef.html
[asmut]: https://doc.rust-lang.org/stable/core/convert/trait.AsMut.html

Let's reimplement our accessor and mutator functions using these traits:

<% highlight_code 'rust' do %>
pub struct UdpPacket<T: AsRef<[u8]>> {
    pub buffer: T
}

impl<T: AsRef<[u8]>> UdpPacket<T> {
    pub fn src_port(&self) -> u16 {
        let data = self.buffer.as_ref();
        NetworkEndian::read_u16(&data[0..2])
    }
}

impl<T: AsRef<[u8]> + AsMut<[u8]>> UdpPacket<T> {
    pub fn set_src_port(&mut self, value: u16) {
        let data = self.buffer.as_mut();
        NetworkEndian::write_u16(&mut data[0..2], value)
    }
}
<% end %>

This solves the problem! The following code typechecks:

<% highlight_code 'rust' do %>
let mut packet = UdpPacket { buffer: vec![0u8; 128] };
let port = packet.src_port();
packet.set_src_port(port + 1);
<% end %>

Note that it is not strictly necessary to have the `T: AsRef<[u8]>` constraint on `UdpPacket`;
I have chosen to keep it for clarity of intent, as well as catching type errors earlier.

Removing the constraint would have shortened the mutator impls; `T: AsMut<[u8]>` would have been
sufficient instead of `AsRef<[u8]> + AsMut<[u8]>`.
Arguably, `AsMut<[u8]>` should extend `AsRef<[u8]>`, but it is too late to do
this backwards-incompatible change.

# Returning interior slices

However, there's still one more issue: many protocols have an opaque payload in their packets.
A naïve way to write an accessor for the payload (which, like with other fields, may not even
be located at a fixed offset) would be to return the slice instead of reading from it:

<% highlight_code 'rust' do %>
impl<T: AsRef<[u8]>> UdpPacket<T> {
    pub fn payload(&self) -> &[u8] {
        let data = self.buffer.as_ref();
        &data[8..]
    }
}

impl<T: AsRef<[u8]> + AsMut<[u8]>> UdpPacket<T> {
    pub fn set_payload(&mut self) -> &mut [u8] {
        let mut data = self.buffer.as_mut();
        &mut data[8..]
    }
}
<% end %>

However, let's consider the context in which such accesssors may be used. For example,
an application could try processing UDP-over-IPv4 and UDP-over-IPv6 requests using the same
codepath, by extracting the payload before processing:

<% highlight_code 'rust' do %>
fn poll() {
    // ...
    let udp_payload: &[u8];
    // ...
    match eth_frame.ethertype() {
        // ...
        EthernetProtocolType::Ipv4 => {
            let ip_packet = try!(Ipv4Packet::new(eth_frame.payload()));
            match try!(Ipv4Repr::parse(&ip_packet)) {
                // ...
                Ipv4Repr { protocol: InternetProtocolType::Udp, src_addr, dst_addr } => {
                    let udp_packet = try!(UdpPacket::new(ip_packet.payload()));
                    udp_payload = udp_packet.data();
                }
            },
        EthernetProtocolType::Ipv6 => {
            let ip_packet = try!(Ipv6Packet::new(eth_frame.payload()));
            match try!(Ipv6Repr::parse(&ip_packet)) {
                // ...
                Ipv6Repr { protocol: InternetProtocolType::Udp, src_addr, dst_addr } => {
                    let udp_packet = try!(UdpPacket::new(ip_packet.payload()));
                    udp_payload = udp_packet.data();
                }
            },
        }
    }
    // ...
    process(udp_payload);
    // ...
}
<% end %>

Trying to build such code will result in a very curious error from a borrow checker:

<% highlight_code 'text' do %>
error: `udp_packet` does not live long enough
   --> src/iface/ethernet.rs:158:21
    |
133 |           let udp_packet = try!(UdpPacket::new(ip_packet.payload()));
    |                                                --------- borrow occurs here
...
158 |       },
    |       ^ `udp_packet` dropped here while still borrowed
...
205 | }
    | - borrowed value needs to live until here
<% end %>

The root cause is that the returned payload slice has the lifetime of the *packet* from
which it was extracted, and not the *storage* to which it is really tied.

# Preserving slice lifetime

Let's try and write the desired signature of `payload()`. There is no lifetime contained
in an `UdpPacket`; it's clear we have to add a lifetime parameter, and this lifetime parameter
should be bound outside of the accessor itself (or it could not outlive the invocation of
the accessor):

<% highlight_code 'rust' do %>
impl<'a, ...> UdpPacket<...> {
    pub fn payload(&self) -> &'a [u8] {
        // ...
    }
}
<% end %>

Now, what would fill in the `...`? A straightforward solution could be adding a (phantom)
lifetime to `UdpPacket`, indicating the lifetime of the storage, and then constraining `T`
to outlive this lifetime:

<% highlight_code 'rust' do %>
pub struct UdpPacket<'a, T: AsRef<[u8]> + 'a> {
    pub buffer:  T,
    pub phantom: PhantomData<&'a [u8]>
}

impl<'a, T: AsRef<[u8]> + 'a> UdpPacket<'a, T> {
    pub fn payload(&self) -> &'a [u8] {
        let data = self.buffer.as_ref();
        &data[8..]
    }
}
<% end %>

However, the borrow checker rejects this code:

<% highlight_code 'text' do %>
error[E0495]: cannot infer an appropriate lifetime for autoref due
              to conflicting requirements
  --> src/main.rs:26:32
   |
26 |         let data = self.buffer.as_ref();
   |                                ^^^^^^
   |
help: consider using an explicit lifetime parameter as shown:
      fn payload(&'a self) -> &'a [u8]
  --> src/main.rs:25:5
   |
25 |     pub fn payload(&self) -> &'a [u8] {
   |     ^
<% end %>

The error is somewhat unhelpful. As [explained by Quxxy][quxxy], the underlying reason is that,
for example, `T` could be `Vec<u8>`; then, the result of `as_ref` would have the lifetime of your struct, not an independent lifetime, as `as_ref` borrows its `self` and borrowing `self` then
just borrows the field.

[quxxy]: https://www.reddit.com/r/rust/comments/5i63se/abstracting_over_mutability/db5sae6/

Instead, one could notice that indirection through the `AsRef` trait is idempotent:
any `&AsRef<T>` is an `AsRef<T>`, and similarly, any `&AsMut<T>` is an `AsMut<T>` is an `AsRef<T>`.
Keeping this in mind, we can rewrite *just* the implementation of `payload()` to introduce
a lifetime constraint for it:

<% highlight_code 'rust' do %>
impl<'a, T: AsRef<[u8]> + ?Sized> Packet<&'a T> {
    pub fn payload(&self) -> &'a [u8] {
        let data = self.buffer.as_ref();
        &data[8..]
    }
}
<% end %>

This works beautifully: the only needed change is adding a few `&` in the code that uses this API.

The reason for the `+ ?Sized` constraint is a bit subtle. Rust has an implicit `+ Sized` constraint
on every type parameter by default. Normally, when passing a `&[u8]` in a function defined
in an `impl<T: AsRef<[u8]>> Packet<T>`, this is not an issue because `T` is `&[u8]`, which
is sized (it's a fat pointer, so its size is twice  that of `usize`).

However, when wrapping a `&[u8]` in a function defined in an
`impl<'a, T: AsRef<[u8]> + ?Sized> Packet<&'a T>`, `T` is `[u8]`, which isn't sized. This has
no implications at all outside the binding of the type parameter, since in this case we never
manipulate a bare `T`, only `&T`, so it's sufficient to add the negative constraint.

# Drawbacks

One notable drawback of this way to abstract over mutability is in the contract of the `AsRef`
and `AsMut` traits. Notably, they are not required to return the same pointer when both are
implemented, and they are not required to return the same pointer every time they are invoked.

For safe code, the lack of such guarantees is not a problem. However, bounds checking takes time,
and it is tempting to resort to unsafe code to bypass it; in that case, a maliciously compliant
implementation of `AsRef` and `AsMut` could easily break the assumptions of unsafe code.

If this is a problem, I suggest adding an alternate implementation of these traits, perhaps
`BufferRef` and `BufferMut`, which list these guarantees in their contract, and are unsafe
to implement.

# Practical examples

An example of using this technique for a practical project includes [smoltcp][],
e.g. see [smoltcp's ICMP packet wrapper][icmpwrapper]. (Please note that at this moment
smoltcp itself is in early development and is not ready for use by general public.)

[smoltcp]: https://github.com/m-labs/smoltcp
[icmpwrapper]: https://github.com/m-labs/smoltcp/blob/8a3dee094328b2ac88dc90f2f5abd84ea940b8f6/src/wire/icmpv4.rs#L125-L292

A slightly different but related example is the use of `AsMut<[u8]>` in [log_buffer][],
where it is used to abstract not over mutability *per se* but rather different kinds of
mutable containers; chiefly so that the library could be used for both borrowed mutable
slices and owned vectors.

[log_buffer]: https://github.com/whitequark/rust-log_buffer/blob/master/src/lib.rs#L45-L63

# Conclusions

* Abstracting over mutability in Rust is possible and does not require boilerplate or
  complicated code.
* Although slightly trickier, abstracting over storage lifetime is also possible.
