---
kind: article
created_at: 2017-01-16 21:49:26 +0000
title: "Abstracting over mutability in Rust macros"
tags:
  - software
  - rust
---

Macros can help to avoid bugs in repetitive code. It would be nice if we could reuse the same
macro for `fn(&self)` and `fn(&mut self)` alike, or similar cases. In this note I will show how
to do this.

<!--more-->

Let's say we have an enumeration over many types that present an identical interface:

<% highlight_code 'rust' do %>
pub enum Socket {
    Udp(UdpSocket),
    Tcp(TcpSocket),
    #[doc(hidden)]
    __Nonexhaustive
}
<% end %>

Naively, code for dispatching methods to individual sockets would look something like this:

<% highlight_code 'rust' do %>
impl Socket {
    pub fn process(&mut self, timestamp: u64, ip_repr: &IpRepr,
                   payload: &[u8]) -> Result<(), Error> {
        match self {
            &mut Socket::Udp(ref mut socket) =>
                socket.process(timestamp, ip_repr, payload),
            &mut Socket::Tcp(ref mut socket) =>
                socket.process(timestamp, ip_repr, payload),
            &mut Socket::__Nonexhaustive => unreachable!()
        }
    }

    pub fn dispatch<F, R>(&mut self, timestamp: u64, emit: &mut F) -> Result<R, Error>
            where F: FnMut(&IpRepr, &IpPayload) -> Result<R, Error> {
        match self {
            &mut Socket::Udp(ref mut socket) =>
                socket.dispatch(timestamp, emit),
            &mut Socket::Tcp(ref mut socket) =>
                socket.dispatch(timestamp, emit),
            &mut Socket::__Nonexhaustive => unreachable!()
        }
    }
}
<% end %>

We could simplify it with a macro:

<% highlight_code 'rust' do %>
macro_rules! dispatch_socket {
    ($self_:expr, |$socket:ident| $code:expr) => ({
        match $self_ {
            &mut Socket::Udp(ref mut $socket) => $code,
            &mut Socket::Tcp(ref mut $socket) => $code,
            &mut Socket::__Nonexhaustive => unreachable!()
        }
    })
}

impl Socket {
    pub fn process(&mut self, timestamp: u64, ip_repr: &IpRepr,
                   payload: &[u8]) -> Result<(), Error> {
        dispatch_socket!(self, |socket| socket.process(timestamp, ip_repr, payload))
    }

    pub fn dispatch<F, R>(&mut self, timestamp: u64, emit: &mut F) -> Result<R, Error>
            where F: FnMut(&IpRepr, &IpPayload) -> Result<R, Error> {
        dispatch_socket!(self, |socket| socket.process(timestamp, ip_repr, payload))
    }
}
<% end %>

However, what do we do to implement a method that accepts a `&self`? It seems inelegant
to duplicate the macro when the entire point of this exercise is reduction in duplication.

Let's try to parameterize a macro over the `mut` qualifier. It's not a valid syntactic entity
itself, so we can only represent it as a token tree:

<% highlight_code 'rust' do %>
macro_rules! dispatch_socket {
    ($self_:expr, |$socket:ident $mut_:tt| $code:expr) => ({
        match $self_ {
            &$mut_ Socket::Udp(ref $mut_ $socket) => $code,
            &$mut_ Socket::Tcp(ref $mut_ $socket) => $code,
            &$mut_ Socket::__Nonexhaustive => unreachable!()
        }
    })
}
<% end %>

Unfortunately this doesn't work for the non-`mut` case as `$mut_:tt` matcher will eat
the delimiting `|`. We can't surround it with delimiters, like `[ $mut_:tt ]` either, for
the same reason. We can, however, make it match zero or more `mut`s!

<% highlight_code 'rust' do %>
macro_rules! dispatch_socket {
    ($self_:expr, |$socket:ident [$( $mut_:tt )*]| $code:expr) => ({
        match $self_ {
            &$( $mut_ )* Socket::Udp(ref $( $mut_ )* $socket) => $code,
            &$( $mut_ )* Socket::Tcp(ref $( $mut_ )* $socket) => $code,
            &$( $mut_ )* Socket::__Nonexhaustive => unreachable!()
        }
    })
}
<% end %>

I wish Rust added first-class support for a zero-or-one matcher in macros by example, but
meanwhile, this works too.
