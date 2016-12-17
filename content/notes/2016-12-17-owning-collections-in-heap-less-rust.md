---
kind: article
created_at: 2016-12-17 09:47:34 +0000
title: "Owning collections in heap-less Rust"
tags:
  - software
  - rust
---

For tasks such as buffering, when a heap is available, it's ergonomic to have a data structure
own the buffer. However, with no heap, owning a buffer (which can now only be an array, on stack
or in a `static mut`) would make that data structure have a variable size, which precludes
most genericism. In this note I explore some solutions to this issue.

* toc
{:toc}

# Motivation

I am writing a networking stack. A platform where a network stack is deployed often has a heap,
but just as often it does not; a networking stack that does not require a heap also provides
much tighter guarantees on packet processing latency, so it is desirable in its own regard.

Let's focus on two details in a networking stack:

  * An interface has a set of assigned addresses, which can dynamically change.
  * An interface has a set of open sockets, which all contain buffers, and which can dynamically
    change.

# Set of assigned addresses

Let's start with the set of assigned addresses. An address, for the purpose of this note,
will be:

<% highlight_code 'rust' do %>
pub enum Address {
    Invalid,
    Ipv4([u8; 4])
}

impl Address {
    pub fn is_invalid(&self) -> bool {
        match self {
            &Address::Invalid => true,
            _ => false
        }
    }
}
<% end %>

The API should:

  * Permit reading addresses;
  * Permit replacing addresses;
  * Permit appending addresses, if used with a collection.
  * Prohibit adding invalid addresses to the set.

## Borrowing a mutable slice

A naïve solution would be to borrow a mutable slice of addresses:

<% highlight_code 'rust' do %>
pub struct Interface<'a> {
    addresses: &'a mut [Address]
}

impl<'a> Interface<'a> {
    pub fn new(addresses: &'a mut [Address]) -> Interface<'a> {
        Interface { addresses: addresses }
    }

    pub fn addresses(&'a self) -> &'a [Address] {
        self.addresses
    }

    pub fn set_addresses(&mut self, addrs: &'a mut [Address]) {
        for addr in addrs.iter() {
            if addr.is_invalid() { panic!("invalid address") }
        }
        self.addresses = addrs
    }
}
<% end %>

This works as expected, but can we improve the ergonomics of the case where we have the heap?

## Using `BorrowMut`

We can parameterize `Interface` over not just the lifetime of the address slice but rather
over anything that permits borrowing a slice:

<% highlight_code 'rust' do %>
use core::borrow::BorrowMut;

pub struct Interface<
    AddressesT: BorrowMut<[Address]>
> {
    addresses: AddressesT
}

impl<
    AddressesT: BorrowMut<[Address]>
> Interface<AddressesT> {
    pub fn new(addresses: AddressesT) -> Interface<AddressesT> {
        Interface { addresses: addresses }
    }

    pub fn addresses(&self) -> &[Address] {
        self.addresses.borrow()
    }

    pub fn set_addresses(&mut self, addrs: AddressesT) {
        for addr in addrs.borrow().iter() {
            if addr.is_invalid() { panic!("invalid address") }
        }
        self.addresses = addrs
    }
}
<% end %>

## Improving updates

In case when heap is used (e.g. `AddressesT` is `Vec<Address>`), even updating a single address
would require allocating a new vector and then deallocating the old one, which is inefficient.
In case without heap (e.g. `AddressesT` is `&mut [Address]`), updating an arbitrary number
of times isn't possible at all! Fortunately, both issues can be solved in the same way:

<% highlight_code 'rust' do %>
    pub fn update_addresses<R, F>(&mut self, f: F)
            where F: FnOnce(&mut [Address]) -> R {
        f(self.addresses.borrow_mut());
        for addr in self.addresses.borrow().iter() {
            if addr.is_invalid() { panic!("invalid address") }
        }
    }
<% end %>

A downside of this solution is that it only works if the update function panics on error. I do not
see an easy way to handle errors through `Result` using this pattern.

## Specializing for collections

All collections may be `BorrowMut<T>`, but some may expose more methods than others---
e.g. `Vec<T>` permits appending. We can specialize the `impl Interface` to permit appending
to the set of addresses:

<% highlight_code 'rust' do %>
impl Interface<Vec<Address>> {
    pub fn add_address(&mut self, addr: Address) {
        self.addresses.push(addr)
    }
}
<% end %>

# Set of sockets

Let's consider a simplified model again. A socket, using the techniques above to parameterize
it with different kinds of buffers, could be represented with:

<% highlight_code 'rust' do %>
pub struct TcpSocket<
    BufferT: BorrowMut<[u8]>
> {
    rx_buffer: BufferT,
    tx_buffer: BufferT,
    // ...
}

impl<
    BufferT: BorrowMut<[u8]>
> TcpSocket<BufferT> {
    pub fn new(rx_buffer: BufferT, tx_buffer: BufferT) -> TcpSocket<BufferT> {
        TcpSocket { rx_buffer: rx_buffer, tx_buffer: tx_buffer }
    }

    pub fn recv(&mut self, data: &mut [u8]) {
        // dequeue from self.rx_buffer into data
    }

    pub fn send(&mut self, data: &[u8]) {
        // enqueue from data into self.tx_buffer
    }
}
<% end %>

## Generalizing over type of sockets

There could be different kinds of sockets, perhaps also an `UdpSocket`, and they would use
a different type for the buffer (an `UdpSocket` would need to store the remote endpoint as
well as the payload, at the very least). To accomodate this, let's define a trait that
the network interface could use to dispatch packets from the network and send queued packets
to the network:

<% highlight_code 'rust' do %>
pub trait Socket {
    fn receive(&mut self, data: &[u8]) -> bool;
    fn transmit(&mut self) -> &mut [u8];
}

impl<
    BufferT: BorrowMut<[u8]>
> Socket for TcpSocket<BufferT> {
    fn receive(&mut self, data: &[u8]) -> bool {
        // enqueue data into self.rx_buffer
    }

    fn transmit(&mut self) -> &mut [u8] {
        // dequeue data from self.tx_buffer
    }

}
<% end %>

Since the trait does not (and can not) expose the type parameters, the only way the network
interface could manage the socket is through a slice of pointers to the trait object:

<% highlight_code 'rust' do %>
use std::marker::PhantomData;

pub struct Interface<'a,
    SocketsT: BorrowMut<[&'a mut Socket]>
> {
    sockets: SocketsT,
    phantom: PhantomData<&'a mut Socket>
}

impl<'a,
    SocketsT: BorrowMut<[&'a mut Socket]>
> Interface<'a, SocketsT> {
    pub fn new(sockets: SocketsT) -> Interface<'a, SocketsT> {
        Interface {
            sockets: sockets,
            phantom: PhantomData
        }
    }

    pub fn poll(&mut self, rx_data: &[u8]) {
        for socket in self.sockets.borrow_mut() {
            if socket.receive(rx_data) {
                break
            }
        }
    }
}
<% end %>

## Accessing sockets held by interface

This is great, but how does the application code actually access the socket? Since the interface
holds a mutable pointer to the socket, all access would have to be requested through the interface:

<% highlight_code 'rust' do %>
    pub fn with_sockets<R, F>(&mut self, f: F) -> R
            where F: FnOnce(&mut [&'a mut Socket]) -> R {
        f(self.sockets.borrow_mut())
    }
<% end %>

This solves the problem of obtaining the pointer, but that's still a `&Socket`. There is
the [Any trait][any], but we cannot use it because it requires the contained value to have
a `'static` bound; a socket with e.g. a buffer borrowed from the stack would not have one.

[any]: https://doc.rust-lang.org/nightly/std/any/trait.Any.html

To solve this, we can try cloning the implementation of `Any` (which regretfully restricts
us to nightly, as there's no way to get the [TypeId][] of a type that's not `'static`),
and so we have to redeclare the intinsic ourselves:

[TypeId]: https://doc.rust-lang.org/nightly/std/any/struct.TypeId.html

<% highlight_code 'rust' do %>
impl Socket {
    pub fn downcast<T, R, F>(&mut self, f: F) -> R
            where T: Socket, F: FnOnce(&mut T) -> R  {
        unsafe { /* dark magic */ }
    }
}
<% end %>

## Writing application code

Unfortunately, this doesn't actually work. The `downcast` function would require spelling out
the entire type, including the type of the buffer inside the socket:

<% highlight_code 'rust' do %>
fn main() {
    let mut rx_buffer = [0; 2048];
    let mut tx_buffer = [0; 2048];
    let mut socket = TcpSocket::new(&mut rx_buffer[..], &mut tx_buffer[..]);
    let mut sockets: [&mut Socket; 1] = [&mut socket];
    let mut interface = Interface::new(&mut sockets[..]);

    loop {
        interface.poll();
        interface.with_sockets(|sockets| {
            sockets[0].downcast::<TcpSocket<&mut [u8]>, _, _>(|socket| {
                // ...
            });
        })
    }
}
<% end %>

All is well until we add the `downcast` call---but once we do, compilation fails with an error:

<% highlight_code 'text' do %>
rustc 1.13.0 (2c6933acc 2016-11-07)
error: `rx_buffer` does not live long enough
  --> <anon>:87:42
   |
87 |     let mut socket = TcpSocket::new(&mut rx_buffer[..], &mut tx_buffer[..]);
   |                                          ^^^^^^^^^ does not live long enough
...
98 | }
   | - borrowed value only lives until here
   |
   = note: borrowed value must be valid for the static lifetime...
<% end %>

It's not clear to me why exactly, but the `downcast` call implicitly adds a `'static` lifetime,
so that the constraint becomes `T: Socket + 'static`; this appears to be a dead end.

# Rethinking ownership

If we step back, it becomes clear that that the root cause is the fact that the socket
is parameterized. If that wasn't the case, we would not need any tricky downcasting, because
we could simply use an enum.

To get rid of a parameter, we'll (sadly) have to introduce a configuration feature. To make
a type that wraps either a reference or an owned collection, we need to use indirection---
through a heap allocation---and that means using Box. Something like:

<% highlight_code 'rust' do %>
use core::ops::{Deref, DerefMut};
use core::borrow::BorrowMut;
use core::fmt;

#[cfg(feature = "std")]
use std::boxed::Box;
#[cfg(feature = "std")]
use std::vec::Vec;

pub enum Managed<'a, T: 'a + ?Sized> {
    Borrowed(&'a mut T),
    #[cfg(feature = "std")]
    Owned(Box<BorrowMut<T>>)
}

impl<'a, T: 'a + fmt::Debug + ?Sized> fmt::Debug for Managed<'a, T> {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "Managed::from({:?})", self.deref())
    }
}

impl<'a, 'b: 'a, T: 'b + ?Sized> From<&'b mut T> for Managed<'b, T> {
    fn from(value: &'b mut T) -> Self {
        Managed::Borrowed(value)
    }
}

#[cfg(feature = "std")]
impl<T, U: BorrowMut<T> + 'static> From<Box<U>> for Managed<'static, T> {
    fn from(value: Box<U>) -> Self {
        Managed::Owned(value)
    }
}

#[cfg(feature = "std")]
impl<T: 'static> From<Vec<T>> for Managed<'static, [T]> {
    fn from(mut value: Vec<T>) -> Self {
        value.shrink_to_fit();
        Managed::Owned(Box::new(value))
    }
}

impl<'a, T: 'a + ?Sized> Deref for Managed<'a, T> {
    type Target = T;

    fn deref(&self) -> &Self::Target {
        match self {
            &Managed::Borrowed(ref value) => value,
            #[cfg(feature = "std")]
            &Managed::Owned(ref value) => (**value).borrow()
        }
    }
}

impl<'a, T: 'a + ?Sized> DerefMut for Managed<'a, T> {
    fn deref_mut(&mut self) -> &mut Self::Target {
        match self {
            &mut Managed::Borrowed(ref mut value) => value,
            #[cfg(feature = "std")]
            &mut Managed::Owned(ref mut value) => (**value).borrow_mut()
        }
    }
}
<% end %>

(The weird `(**value).borrow_mut()` construct is necessary because of [Rust issue 38425][38425]).

[38425]: https://github.com/rust-lang/rust/issues/38425

## Using `Managed<T>` in libraries

Now, let's rewrite the sockets using `Managed<T>`; this will considerably simplify them.
To demonstrate the composability of `Managed<T>` I am going to use UDP sockets for this
example, since UDP sockets should own a collection of packet buffers.

<% highlight_code 'rust' do %>
mod managed;
use managed::Managed;

pub struct UdpBuffer<'a> {
    storage: Managed<'a, [u8]>,
    // endpoint: SocketAddr,
    // ...
}

impl<'a> UdpBuffer<'a> {
    pub fn new<T>(storage: T) -> UdpBuffer<'a>
            where T: Into<Managed<'a, [u8]>> {
        UdpBuffer { storage: storage.into() }
    }
}

pub struct UdpSocket<'a, 'b: 'a> {
    rx_buffer: Managed<'a, [UdpBuffer<'b>]>,
    tx_buffer: Managed<'a, [UdpBuffer<'b>]>,
    // ...
}

impl<'a, 'b: 'a> UdpSocket<'a, 'b> {
    pub fn new<T>(rx_buffer: T, tx_buffer: T) -> Socket<'a, 'b>
            where T: Into<Managed<'a, [UdpBuffer<'b>]>> {
        Socket::Udp(UdpSocket {
            rx_buffer: rx_buffer.into(),
            tx_buffer: tx_buffer.into()
        })
    }

    pub fn recv(&mut self, data: &mut [u8]) {
        // dequeue from self.rx_buffer into data
    }

    pub fn send(&mut self, data: &[u8]) {
        // enqueue from data into self.tx_buffer
    }
}

pub enum Socket<'a, 'b: 'a> {
    Udp(UdpSocket<'a, 'b>),
    // Tcp(TcpSocket<'a, 'b>),
    // ...
}

impl<'a, 'b: 'a> Socket<'a, 'b> {
    fn receive(&mut self, data: &[u8]) -> bool {
        // forward to the contained socket
    }

    fn transmit(&mut self) -> &mut [u8] {
        // forward to the contained socket
    }
}
<% end %>

To elegantly downcast `Socket` to e.g. concrete `TcpSocket`, let's introduce a helper trait:

<% highlight_code 'rust' do %>
pub trait AsSocket<T> {
    fn as_socket(&mut self) -> &mut T;
}

impl<'a, 'b> AsSocket<UdpSocket<'a, 'b>> for Socket<'a, 'b> {
    fn as_socket(&mut self) -> &mut UdpSocket<'a, 'b> {
        match self {
            &mut Socket::Udp(ref mut socket) => socket,
            _ => panic!(".as_socket::<UdpSocket> called on wrong socket type")
        }
    }
}
<% end %>

And finally, the interface. Note how the interface still uses `BorrowMut`---this preserves
the ability to add methods on the interface that are specialized on the concrete type of
`SocketT`, e.g. `add_socket` when `SocketT` is `Vec<Socket>`:

<% highlight_code 'rust' do %>
pub struct Interface<'a, 'b: 'a,
    SocketsT: BorrowMut<[Socket<'a, 'b>]>
> {
    sockets: SocketsT,
    phantom: PhantomData<Socket<'a, 'b>>
}

impl<'a, 'b,
    SocketsT: BorrowMut<[Socket<'a, 'b>]>
> Interface<'a, 'b, SocketsT> {
    pub fn new(sockets: SocketsT) -> Interface<'a, 'b, SocketsT> {
        Interface {
            sockets: sockets,
            phantom: PhantomData
        }
    }

    pub fn sockets(&mut self) -> &mut [Socket<'a, 'b>] {
        self.sockets.borrow_mut()
    }

    pub fn poll(&mut self, rx_data: &[u8]) {
        // ...
    }
}
<% end %>

## Using `Managed<T>` in applications

Finally, let's confirm that we can use the resulting API in code that runs both with and
without heap. The variant with heap is easy to write:

<% highlight_code 'rust' do %>
fn main() {
    let tx_buffer = UdpBuffer::new(vec![0; 2048]);
    let rx_buffer = UdpBuffer::new(vec![0; 2048]);
    let socket = UdpSocket::new(vec![tx_buffer], vec![rx_buffer]);
    let mut interface = Interface::new(vec![socket]);
    loop {
        interface.poll();

        let socket: &mut UdpSocket = interface.sockets()[0].as_socket();
        let mut data = [0; 8];
        socket.recv(&mut data);
        socket.send(&data)
    }
}
<% end %>

The variant without heap is a bit more tricky:

<% highlight_code 'rust' do %>
fn main() {
    let mut tx_buffer_data = [0; 2048];
    let mut rx_buffer_data = [0; 2048];
    let tx_buffer = UdpBuffer::new(&mut tx_buffer_data[..]);
    let rx_buffer = UdpBuffer::new(&mut rx_buffer_data[..]);
    let mut tx_buffers = [tx_buffer];
    let mut rx_buffers = [rx_buffer];
    let socket = UdpSocket::new(&mut tx_buffers[..], &mut rx_buffers[..]);
    let mut sockets = [socket];
    let mut interface = Interface::new(&mut sockets[..]);

    loop {
        interface.poll();

        let socket: &mut UdpSocket = interface.sockets()[0].as_socket();
        let mut data = [0; 8];
        socket.recv(&mut data);
        socket.send(&data)
    }
}
<% end %>

## Lifetime pitfalls

The heap-less variant as well as `UdpSocket` have some implementation subtleties. For example,
my initial implementation of `UdpSocket` was as follows:

<% highlight_code 'rust' do %>
pub struct UdpSocket<'a> {
    rx_buffer: Managed<'a, [UdpBuffer<'a>]>,
    tx_buffer: Managed<'a, [UdpBuffer<'a>]>,
    // ...
}
<% end %>

While it's not incorrect at the first glance (and indeed the library code typechecks), trying
to use this implementation without a heap would run into a snag: the lifetimes of the buffer
and the buffer container get tied together, and borrow checker rejects the code with
"dropped here while still borrowed".

Similarly, writing the initialization code with the statements interleaved like this won't work,
even if it may look more natural:

<% highlight_code 'rust' do %>
fn main() {
    let mut tx_buffer_data = [0; 2048];
    let tx_buffer = UdpBuffer::new(&mut tx_buffer_data[..]);
    let mut tx_buffers = [tx_buffer];
    let mut rx_buffer_data = [0; 2048];
    let rx_buffer = UdpBuffer::new(&mut rx_buffer_data[..]);
    let mut rx_buffers = [rx_buffer];
    let socket = UdpSocket::new(&mut tx_buffers[..], &mut rx_buffers[..]);
    // ...
}
<% end %>

In this case, while the lifetime of individual `UdpBuffer`s is always longer than the lifetime
of their data, the *unified* lifetime of both `UdpBuffer`s is not longer than the unified lifetime
of their data.

# Conclusions

  * Rust admits a highly ergonomic interface for logically owning collections that works
    both with code that has a heap, and code that does not.
  * Logical ownership of collections is composable, although every level of nesting requires
    adding another lifetime parameter; this may result in issues when using e.g. trait
    associated types.
  * Using logical ownership with mutable pointers has some minor pitfalls due to how lifetimes
    are unified.
  * The implementation of `Managed<T>` requires a feature flag and changes depending on whether
    `libstd` is available; however, since it is desirable that `Managed<T>` would be available
    on systems without `libstd`, and that means that the `Managed::Owned` variant would switch
    between `std::boxed::Box` and `alloc::boxed::Box`, which requires a feature flag anyway.

# Future work

I am planning to extract `Managed<T>` as a separate library; see the [rust-managed][repo]
repository.

[repo]: https://github.com/whitequark/rust-managed
