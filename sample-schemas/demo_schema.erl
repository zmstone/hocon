-module(demo_schema).

-include_lib("typerefl/include/types.hrl").

-type ip() :: ipv4() | ipv6().
-type ipv4() :: {0..255, 0..255, 0..255, 0..255}.
-type ipv6() :: {0..65535, 0..65535, 0..65535, 0..65535, 0..65535, 0..65535, 0..65535, 0..65535}.

-type birthdays() :: [#{m := 1..12, d := 1..31}].

-reflect_type([ip/0, birthdays/0]).

-export([namespaces/0, fields/1]).

namespaces() -> ["foo", "a.b"].

fields("foo") ->
    [ {"setting", fun setting/1}
    , {"endpoint", fun endpoint/1}
    , {"greet", fun greet/1}
    , {"numbers", fun numbers/1}
    ];

fields("a.b") ->
    [ {"birthdays", fun birthdays/1}
    ].

setting(mapping) -> "app_foo.setting";
setting(type) -> string();
setting(converter) -> fun to_string/1;
setting(override_env) -> "MY_OVERRIDE";
setting(_) -> undefined.

endpoint(mapping) -> "app_foo.endpoint";
endpoint(type) -> ip();
endpoint(converter) -> fun to_ip/1;
endpoint(_) -> undefined.

greet(mapping) -> "app_foo.greet";
greet(type) -> typerefl:regexp_string("^hello$");
greet(converter) -> fun to_string/1;
greet(_) -> undefined.

numbers(mapping) -> "app_foo.numbers";
numbers(type) -> list(integer());
numbers(_) -> undefined.

birthdays(mapping) -> "a.b.birthdays";
birthdays(type) -> birthdays();
birthdays(_) -> undefined.

to_ip(Bin) when is_binary(Bin) ->
    to_ip(binary_to_list(Bin));
to_ip(Str) when is_list(Str) ->
    case inet:parse_address(Str) of
        {ok, Addr} ->
            Addr;
        {error, einval} ->
            Str
    end;
to_ip(V) -> V.

to_string(Int) when is_integer(Int) ->
    integer_to_list(Int);
to_string(Bin) when is_binary(Bin) ->
    binary_to_list(Bin);
to_string(V) -> V.
