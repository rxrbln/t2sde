% hello.erl
-module(hello).
-export([hello_world/0]).

hello_world() -> io:fwrite("hello from Erlang.\n").
