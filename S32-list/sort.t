use v6;
use Test;
use lib $?FILE.IO.parent(2).add("packages/Test-Helpers");
use Test::Util;

plan 38;

# L<S32::Containers/"List"/"=item sort">

{
    my @a = (4, 5, 3, 2, 5, 1);
    my @e = (1 .. 5, 5);

    my @s = sort(@a);
    is(@s, @e, 'array of numbers was sorted');
}

{
    my @a = (4, 5, 3, 2, 5, 1);
    my @e = (1 .. 5, 5);

    my @s = sort @a;
    is(@s, @e, 'array of numbers was sorted (w/out parens)');
}

{
    # This test used to have NaN in it, but that is nonsensical.
    #                                          --colomon

    my @a = (1.1,2,-3.05,0.1,Inf,42,-1e-07,-Inf).sort;
    my @e = (-Inf,-3.05,-1e-07,0.1,1.1,2,42,Inf);
    my @s = sort @a;
    is(@s, @e, 'array of mixed numbers including Inf');
}

{
    my @a = (4, 5, 3, 2, 5, 1);
    my @e = (1 .. 5, 5);

    my @s = @a.sort;
    is(@s, @e, 'array of numbers was sorted (using invocant form)');
}

{
    my @a = (2, 45, 6, 1, 3);
    my @e = (1, 2, 3, 6, 45);

    my @s = sort { $^a <=> $^b }, @a;
    is(@s, @e, '... with explicit spaceship');
}

{
    my @a = (2, 45, 6, 1, 3);
    my @e = (1, 2, 3, 6, 45);

    my @s = @a.sort: { $^a <=> $^b };
    is(@s, @e, '... with explicit spaceship (using invocant form)');
}

{
    my @a = (2, 45, 6, 1, 3);
    my @e = (45, 6, 3, 2, 1);

    my @s = sort { $^b <=> $^a }, @a;
    is(@s, @e, '... reverse sort with explicit spaceship');
}

{
    my @a = (2, 45, 6, 1, 3);
    my @e = (45, 6, 3, 2, 1);

    my @s = @a.sort: { $^b <=> $^a };
    is(@s, @e, '... reverse sort with explicit spaceship (using invocant form)');
}

{
    my @a = <foo bar gorch baz>;
    my @e = <bar baz foo gorch>;

    my @s = sort(@a);
    is(@s, @e, 'array of strings was sorted');
}

{
    my @a = <foo bar gorch baz>;
    my @e = <bar baz foo gorch>;

    my @s = sort @a;
    is(@s, @e, 'array of strings was sorted (w/out parens)');
}

{
    my @a = <foo bar gorch baz>;
    my @e = <bar baz foo gorch>;

    my @s = @a.sort;
    is(@s, @e, 'array of strings was sorted (using invocant form)');
}

{
    my @a = <daa boo gaa aaa>;
    my @e = <aaa boo daa gaa>;

    my @s = sort { $^a cmp $^b }, @a;
    is(@s, @e, '... with explicit cmp');
}

{
    my @a = <daa boo gaa aaa>;
    my @e = <aaa boo daa gaa>;

    my @s = @a.sort: { $^a cmp $^b };
    is(@s, @e, '... with explicit cmp (using invocant form)');
}

{
    my %a = (4 => 'a', 1 => 'b', 2 => 'c', 5 => 'd', 3 => 'e');
    my @e = (4, 1, 2, 5, 3);

    my @s = sort -> $a, $b { %a{$a} cmp %a{$b} }, %a.keys;
    is(@s, @e, '... sort keys by string value');
}

{
    my %a = (4 => 'a', 1 => 'b', 2 => 'c', 5 => 'd', 3 => 'e');
    my @e = (4, 1, 2, 5, 3);

    my @s = %a.keys.sort: -> $a, $b { %a{$a} cmp %a{$b} };
    is(@s, @e, '... sort keys by string value (using invocant form)');
}

{
    my %a = ('a' => 4, 'b' => 1, 'c' => 2, 'd' => 5, 'e' => 3);
    my @e = <b c e a d>;

    my @s = sort -> $a, $b { %a{$a} <=> %a{$b} }, %a.keys;
    is(@s, @e, '... sort keys by numeric value');
}

{
    my %a = ('a' => 4, 'b' => 1, 'c' => 2, 'd' => 5, 'e' => 3);
    my @e = <b c e a d>;

    my @s = %a.keys.sort: -> $a, $b { %a{$a} <=> %a{$b} };
    is(@s, @e, '... sort keys by numeric value (using invocant form)');
}

{
    my %map = (p => 1, e => 2, r => 3, l => 4);

    is <r e p l>.sort({ %map{$_} }).join, 'perl',
            'can sort with automated Schwartzian Transform';

    my @s = %map.sort: { .value };
    isa-ok(@s[0], Pair, '%hash.sort returns a List of Pairs');
    is (@s.map: { .key }).join, 'perl', 'sort with unary sub'
}


{
    is (<P e r l 6>.sort: { 0; }).join, 'Perl6',
    'sort with arity 0 closure is stable';

    my @a = ([5, 4], [5, 5], [5, 6], [0, 0], [1, 2], [1, 3], [0, 1], [5, 7]);

    {
        my @s = @a.sort: { .[0] };

        ok ([<] @s.map({.[1]})), 'sort with arity 1 closure is stable';
    }

    {
        my @s = @a.sort: { $^a.[0] <=> $^b.[0] };

        ok ([<] @s.map({.[1]})), 'sort with arity 2 closure is stable';
    }
}

##  XXX pmichaud, 2008-07-01:  .sort should work on non-list values
{
    is ~42.sort, "42", "method form of sort should work on numbers";
    is ~"str".sort, "str", "method form of sort should work on strings";
    is ~(42,).sort, "42",  "method form of sort should work on lists";
}

# RT #67010
{
    my @list = 1, 2, Code, True;
    quietly lives-ok { @list.sort: { $^a cmp $^b } }, 'sort by class name';
}

# RT #68112
{
    sub foo () { 0 }   #OK not used
    throws-like { EVAL '(1..10).sort(&foo)' }, Exception,
        'sort does not accept 0-arity sub';
    throws-like '(1..10).sort(&rand)', Exception,
        'sort does not accept &rand';
}

# RT #71258 (can sort a class without parrot internal error)
{
    class RT71258_1 { };

    my @sorted;

    lives-ok { @sorted = (RT71258_1.new, RT71258_1.new).sort },
        'sorting by stringified class instance (name and memory address)';
}

# RT #128779
{
    my &code-method = *.sort;
    my &code-sub    =  &sort;
    isa-ok code-method(<y z x>), Seq, '.sort stored in a sub returns a List';
    isa-ok code-sub(   <y z x>), Seq, '&sort stored in a sub returns a List';
}

# RT #126921
isa-ok (<2 1 3>   .sort), Seq, 'detached .sort returns a List';

# RT #126859
isa-ok (*.sort)(<2 3 1>), Seq, 'auto-primed *.sort returns a Seq';

# RT #130866
eval-lives-ok ｢.elems, .sort with @｣,
    '.sort on reified empty array does not crash';

# https://github.com/rakudo/rakudo/issues/1472
subtest 'degenerate cases' => {
    plan 13;

    is-deeply (    ).sort,               (    ).Seq, 'empty, no args';
    is-deeply (    ).sort(-*),           (    ).Seq, 'empty, 1-arity';
    is-deeply (    ).sort({$^a < $^b}),  (    ).Seq, 'empty, 2-arity';

    is-deeply (1,  ).sort,               (1,  ).Seq, '1 item, no args';
    is-deeply (1,  ).sort(-*),           (1,  ).Seq, '1 item, 1-arity';
    is-deeply (1,  ).sort({$^a < $^b}),  (1,  ).Seq, '1 item, 2-arity';

    is-deeply (2, 1).sort,               (1, 2).Seq, '2-item, no args (1)';
    is-deeply (1, 2).sort,               (1, 2).Seq, '2-item, no args (2)';
    is-deeply (1, 2).sort(-*),           (2, 1).Seq, '2-item, 1-arity (1)';
    is-deeply (2, 1).sort(-*),           (2, 1).Seq, '2-item, 1-arity (2)';

    # True => 1  => swap
    is-deeply (1, 2).sort({$^a < $^b}),  (2, 1).Seq, '2-item, 2-arity (2)';
    # False => 0 => leave as is
    is-deeply (2, 1).sort({$^a < $^b}),  (2, 1).Seq, '2-item, 2-arity (1)';
    # -1 => leave as is
    is-deeply (2, 1).sort(-> $, $ {-1}), (2, 1).Seq, '2-item, 2-arity (3)';
}

# https://github.com/rakudo/rakudo/issues/1739
is-eqv <a c b>.sort(&lc), <a b c>.Seq, 'no crashes when using &lc in .sort';

# R#2937
{
    is-deeply sort( {1}, ^2), (0,1),
      'is sorting a 2 elem list with a mapper stable?';
}

# vim: ft=perl6
