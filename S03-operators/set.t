use v6;
use Test;

plan 292;

sub showset($s) { $s.keys.sort.join(' ') }
sub showkv($x) { $x.sort.map({ .key ~ ':' ~ .value }).join(' ') }

my $s = set <I'm afraid it isn't your day>;
my $sh = SetHash.new(<I'm afraid it is>); # Tom Stoppard
my $b = bag <Whoever remains for long here in this earthly life will enjoy and endure more than enough>; # Seamus Heaney
my $bh = BagHash.new(<Come, take your bread with joy, and your wine with a glad heart>); # Ecclesiastes 9:7

# Is an element of

for &infix:<∈>, "∈", &infix:<(elem)>, "(elem)" -> &op, $name {
    for
      "afraid",  $s,
      "afraid",  $sh,
      "earthly", $b,
      "your",    $bh,
      "d",       <a b c d e>
    -> $left, $right {
        ok op($left,$right), "$left is $name of $right.^name()";
    }
}

# Is not an element of

for &infix:<∉>, "∈", &infix:<!(elem)>, "!(elem)" -> &op, $name {
    for
      "marmoset", $s,
      "marmoset", $sh,
      "marmoset", $b,
      "marmoset", $bh,
      "marmoset", <a b c d e>
    -> $left, $right {
        ok op($left,$right), "$left is $name of $right.^name()";
    }
}

# Contains

for &infix:<∋>, "∋", &infix:<(cont)>, "(cont)" -> &op, $name {
    for
      $s,          "afraid",
      $sh,         "afraid",
      $b,          "earthly",
      $bh,         "your",
      <a b c d e>, "d"
    -> $left, $right {
        ok op($left,$right), "$left.^name() $name $right";
    }
}

# Does not contain

for &infix:<∌>, "∌", &infix:<!(cont)>, "!(cont)" -> &op, $name {
    for
      $s,          "marmoset",
      $sh,         "marmoset",
      $b,          "marmoset",
      $bh,         "marmoset",
      <a b c d e>, "marmoset"
    -> $left, $right {
        ok op($left,$right), "$left.^name() $name $right";
    }
}

# Union

is showset($s ∪ $s), showset($s), "Set union with itself yields self";
isa-ok ($s ∪ $s), Set, "... and it's actually a Set";
is showset($sh ∪ $sh), showset($sh), "SetHash union with itself yields self (as Set)";
isa-ok ($sh ∪ $sh), Set, "... and it's actually a Set";

is showset($s ∪ $sh), showset(set <I'm afraid it is isn't your day>), "Set union with SetHash works";
isa-ok ($s ∪ $sh), Set, "... and it's actually a Set";
is showset($sh ∪ <blue green>), showset(set <I'm afraid it is blue green>), "SetHash union with array of strings works";
isa-ok ($sh ∪ <blue green>), Set, "... and it's actually a Set";

is showset($s (|) $sh), showset(set <I'm afraid it is isn't your day>), "Set union with SetHash works (texas)";
isa-ok ($s (|) $sh), Set, "... and it's actually a Set (texas)";
is showset($sh (|) <blue green>), showset(set <I'm afraid it is blue green>), "SetHash union with array of strings works (texas)";
isa-ok ($sh (|) <blue green>), Set, "... and it's actually a Set (texas)";

# Intersection

is showset($s ∩ $s), showset($s), "Set intersection with itself yields self";
isa-ok ($s ∩ $s), Set, "... and it's actually a Set";
is showset($sh ∩ $sh), showset($sh), "SetHash intersection with itself yields self (as Set)";
isa-ok ($sh ∩ $sh), Set, "... and it's actually a Set";
is showset($s ∩ $sh), showset(set <I'm afraid it>), "Set intersection with SetHash works";
isa-ok ($s ∩ $sh), Set, "... and it's actually a Set";

is showset($s (&) $sh), showset(set <I'm afraid it>), "Set intersection with SetHash works (texas)";
isa-ok ($s (&) $sh), Set, "... and it's actually a Set (texas)";

# set subtraction

is showset($s (-) $s), showset(∅), "Set subtracted from Set is correct";
isa-ok ($s (-) $s), Set, "... and it's actually a Set";

is showset($s (-) $sh), showset(set <isn't your day>), "SetHash subtracted from Set is correct";
isa-ok ($s (-) $sh), Set, "... and it's actually a Set";
is showset($sh (-) $s), showset(set <is>), "Set subtracted from SetHash is correct";
isa-ok ($sh (-) $s), Set, "... and it's actually a Set";

is showkv($b (-) $s), showkv($b), "Set subtracted from Bag is correct";
isa-ok ($b (-) $s), Bag, "... and it's actually a Bag";
is showset($s (-) $b), showset($s), "Bag subtracted from Set is correct";
isa-ok ($s (-) $b), Bag, "... and it's actually a Bag";

is showset($s (-) $bh), showset(set <I'm afraid it isn't day>), "BagHash subtracted from Set is correct";
isa-ok ($s (-) $bh), Bag, "... and it's actually a Bag";
is showkv($bh (-) $s), showkv(<Come, take your bread with joy, and wine with a glad heart>.Bag), "Set subtracted from BagHash is correct";
isa-ok ($bh (-) $s), Bag, "... and it's actually a Bag";

# symmetric difference

is showset($s (^) $s), showset(∅), "Set symmetric difference with Set is correct";
isa-ok ($s (^) $s), Set, "... and it's actually a Set";

is showset($s (^) $sh), showset(set <is isn't your day>), "SetHash symmetric difference with Set is correct";
isa-ok ($s (^) $sh), Set, "... and it's actually a Set";
is showset($sh (^) $s), showset(set <is isn't your day>), "Set symmetric difference with SetHash is correct";
isa-ok ($sh (^) $s), Set, "... and it's actually a Set";

# RT #122882
is showset($s (^) $s (^) $s), showset(∅), "Set symmetric difference with 3+ args (RT #122882)";
is showset(<a b> (^) <b c> (^) <a d> (^) <a e>), showset(set <c d e>), "Set symmetric difference with 3+ args (RT #122882)";

# symmetric difference with Bag moved to bag.t

# is subset of

ok <your day> ⊆ $s, "'Your day' is subset of Set";
ok $s ⊆ $s, "Set is subset of itself";
ok $s ⊆ <I'm afraid it isn't your day old chum>, "Set is subset of string";

ok ($sh (-) set <is>) ⊆ $sh, "Set is subset of SetHash";
ok $sh ⊆ $sh, "SetHash is subset of itself";
ok $sh ⊆ <I'm afraid it is my day>, "SetHash is subset of string";

nok $s ⊆ $b, "Set is not a subset of Bag";
ok $b ⊆ $b, "Bag is subset of itself";
nok $b ⊆ $s, "Bag is not a subset of Set";

nok $s ⊆ $bh, "Set is not a subset of BagHash";
ok $bh ⊆ $bh, "BagHash is subset of itself";
nok $bh ⊆ $s, "BagHash is not a subset of Set";

ok <your day> (<=) $s, "'Your day' is subset of Set";
ok $s (<=) $s, "Set is subset of itself";
ok $s (<=) <I'm afraid it isn't your day old chum>, "Set is subset of string";

ok ($sh (-) set <is>) (<=) $sh, "Set is subset of SetHash (texas)";
ok $sh (<=) $sh, "SetHash is subset of itself (texas)";
ok $sh (<=) <I'm afraid it is my day>, "SetHash is subset of string (texas)";

nok $s (<=) $b, "Set is not a subset of Bag (texas)";
ok $b (<=) $b, "Bag is subset of itself (texas)";
nok $b (<=) $s, "Bag is not a subset of Set (texas)";

nok $s (<=) $bh, "Set is not a subset of BagHash (texas)";
ok $bh (<=) $bh, "BagHash is subset of itself (texas)";
nok $bh (<=) $s, "BagHash is not a subset of Set (texas)";

# is not a subset of
nok <your day> ⊈ $s, "'Your day' is subset of Set";
nok $s ⊈ $s, "Set is subset of itself";
nok $s ⊈ <I'm afraid it isn't your day old chum>, "Set is subset of string";

nok ($sh (-) set <is>) ⊈ $sh, "Set is subset of SetHash";
nok $sh ⊈ $sh, "SetHash is subset of itself";
nok $sh ⊈ <I'm afraid it is my day>, "SetHash is subset of string";

ok $s ⊈ $b, "Set is not a subset of Bag";
nok $b ⊈ $b, "Bag is subset of itself";
ok $b ⊈ $s, "Bag is not a subset of Set";

ok $s ⊈ $bh, "Set is not a subset of BagHash";
nok $bh ⊈ $bh, "BagHash is subset of itself";
ok $bh ⊈ $s, "BagHash is not a subset of Set";

nok <your day> !(<=) $s, "'Your day' is subset of Set (texas)";
nok $s !(<=) $s, "Set is subset of itself (texas)";
nok $s !(<=) <I'm afraid it isn't your day old chum>, "Set is subset of string (texas)";

nok ($sh (-) set <is>) !(<=) $sh, "Set is subset of SetHash (texas)";
nok $sh !(<=) $sh, "SetHash is subset of itself (texas)";
nok $sh !(<=) <I'm afraid it is my day>, "SetHash is subset of string (texas)";

ok $s !(<=) $b, "Set is not a subset of Bag (texas)";
nok $b !(<=) $b, "Bag is subset of itself (texas)";
ok $b !(<=) $s, "Bag is not a subset of Set (texas)";

ok $s !(<=) $bh, "Set is not a subset of BagHash (texas)";
nok $bh !(<=) $bh, "BagHash is subset of itself (texas)";
ok $bh !(<=) $s, "BagHash is not a subset of Set (texas)";

# is proper subset of

ok <your day> ⊂ $s, "'Your day' is proper subset of Set";
nok $s ⊂ $s, "Set is not proper subset of itself";
ok $s ⊂ <I'm afraid it isn't your day old chum>, "Set is proper subset of string";

ok ($sh (-) set <is>) ⊂ $sh, "Set is proper subset of SetHash";
nok $sh ⊂ $sh, "SetHash is not proper subset of itself";
ok $sh ⊂ <I'm afraid it is my day>, "SetHash is proper subset of string";

nok $s ⊂ $b, "Set is not a proper subset of Bag";
nok $b ⊂ $b, "Bag is not proper subset of itself";
nok $b ⊂ $s, "Bag is not a proper subset of Set";

nok $s ⊂ $bh, "Set is not a proper subset of BagHash";
nok $bh ⊂ $bh, "BagHash is not proper subset of itself";
nok $bh ⊂ $s, "BagHash is not a proper subset of Set";

ok <your day> (<) $s, "'Your day' is proper subset of Set";
nok $s (<) $s, "Set is not proper subset of itself";
ok $s (<) <I'm afraid it isn't your day old chum>, "Set is proper subset of string";

ok ($sh (-) set <is>) (<) $sh, "Set is proper subset of SetHash (texas)";
nok $sh (<) $sh, "SetHash is not proper subset of itself (texas)";
ok $sh (<) <I'm afraid it is my day>, "SetHash is proper subset of string (texas)";

nok $s (<) $b, "Set is not a proper subset of Bag (texas)";
nok $b (<) $b, "Bag is not proper subset of itself (texas)";
nok $b (<) $s, "Bag is not a proper subset of Set (texas)";

nok $s (<) $bh, "Set is not a proper subset of BagHash (texas)";
nok $bh (<) $bh, "BagHash is not proper subset of itself (texas)";
nok $bh (<) $s, "BagHash is not a proper subset of Set (texas)";

# is not a proper subset of

nok <your day> ⊄ $s, "'Your day' is proper subset of Set";
ok $s ⊄ $s, "Set is not proper subset of itself";
nok $s ⊄ <I'm afraid it isn't your day old chum>, "Set is proper subset of string";

nok ($sh (-) set <is>) ⊄ $sh, "Set is proper subset of SetHash";
ok $sh ⊄ $sh, "SetHash is not proper subset of itself";
nok $sh ⊄ <I'm afraid it is my day>, "SetHash is proper subset of string";

ok $s ⊄ $b, "Set is not a proper subset of Bag";
ok $b ⊄ $b, "Bag is not proper subset of itself";
ok $b ⊄ $s, "Bag is not a proper subset of Set";

ok $s ⊄ $bh, "Set is not a proper subset of BagHash";
ok $bh ⊄ $bh, "BagHash is not proper subset of itself";
ok $bh ⊄ $s, "BagHash is not a proper subset of Set";

nok <your day> !(<) $s, "'Your day' is proper subset of Set (texas)";
ok $s !(<) $s, "Set is not proper subset of itself (texas)";
nok $s !(<) <I'm afraid it isn't your day old chum>, "Set is proper subset of string (texas)";

nok ($sh (-) set <is>) !(<) $sh, "Set is proper subset of SetHash (texas)";
ok $sh !(<) $sh, "SetHash is not proper subset of itself (texas)";
nok $sh !(<) <I'm afraid it is my day>, "SetHash is proper subset of string (texas)";

ok $s !(<) $b, "Set is not a proper subset of Bag (texas)";
ok $b !(<) $b, "Bag is not proper subset of itself (texas)";
ok $b !(<) $s, "Bag is not a proper subset of Set (texas)";

ok $s !(<) $bh, "Set is not a proper subset of BagHash (texas)";
ok $bh !(<) $bh, "BagHash is not proper subset of itself (texas)";
ok $bh !(<) $s, "BagHash is not a proper subset of Set (texas)";

# is superset of

ok <your day> R⊇ $s, "'Your day' is reversed superset of Set";
ok $s R⊇ $s, "Set is reversed superset of itself";
ok $s R⊇ <I'm afraid it isn't your day old chum>, "Set is reversed superset of string";

ok ($sh (-) set <is>) R⊇ $sh, "Set is reversed superset of SetHash";
ok $sh R⊇ $sh, "SetHash is reversed superset of itself";
ok $sh R⊇ <I'm afraid it is my day>, "SetHash is reversed superset of string";

nok $s R⊇ $b, "Set is not a reversed superset of Bag";
ok $b R⊇ $b, "Bag is reversed superset of itself";
nok $b R⊇ $s, "Bag is not a reversed superset of Set";

nok $s R⊇ $bh, "Set is not a reversed superset of BagHash";
ok $bh R⊇ $bh, "BagHash is reversed superset of itself";
nok $bh R⊇ $s, "BagHash is not a reversed superset of Set";

ok <your day> R(>=) $s, "'Your day' is reversed superset of Set";
ok $s R(>=) $s, "Set is reversed superset of itself";
ok $s R(>=) <I'm afraid it isn't your day old chum>, "Set is reversed superset of string";

ok ($sh (-) set <is>) R(>=) $sh, "Set is reversed superset of SetHash (texas)";
ok $sh R(>=) $sh, "SetHash is reversed superset of itself (texas)";
ok $sh R(>=) <I'm afraid it is my day>, "SetHash is reversed superset of string (texas)";

nok $s R(>=) $b, "Set is not a reversed superset of Bag (texas)";
ok $b R(>=) $b, "Bag is reversed superset of itself (texas)";
nok $b R(>=) $s, "Bag is not a reversed superset of Set (texas)";

nok $s R(>=) $bh, "Set is not a reversed superset of BagHash (texas)";
ok $bh R(>=) $bh, "BagHash is reversed superset of itself (texas)";
nok $bh R(>=) $s, "BagHash is not a reversed superset of Set (texas)";

# is not a superset of

nok <your day> R⊉ $s, "'Your day' is reversed superset of Set";
nok $s R⊉ $s, "Set is reversed superset of itself";
nok $s R⊉ <I'm afraid it isn't your day old chum>, "Set is reversed superset of string";

nok ($sh (-) set <is>) R⊉ $sh, "Set is reversed superset of SetHash";
nok $sh R⊉ $sh, "SetHash is reversed superset of itself";
nok $sh R⊉ <I'm afraid it is my day>, "SetHash is reversed superset of string";

ok $s R⊉ $b, "Set is not a reversed superset of Bag";
nok $b R⊉ $b, "Bag is reversed superset of itself";
ok $b R⊉ $s, "Bag is not a reversed superset of Set";

ok $s R⊉ $bh, "Set is not a reversed superset of BagHash";
nok $bh R⊉ $bh, "BagHash is reversed superset of itself";
ok $bh R⊉ $s, "BagHash is not a reversed superset of Set";

nok <your day> !R(>=) $s, "'Your day' is reversed superset of Set (texas)";
nok $s !R(>=) $s, "Set is reversed superset of itself (texas)";
nok $s !R(>=) <I'm afraid it isn't your day old chum>, "Set is reversed superset of string (texas)";

nok ($sh (-) set <is>) !R(>=) $sh, "Set is reversed superset of SetHash (texas)";
nok $sh !R(>=) $sh, "SetHash is reversed superset of itself (texas)";
nok $sh !R(>=) <I'm afraid it is my day>, "SetHash is reversed superset of string (texas)";

ok $s !R(>=) $b, "Set is not a reversed superset of Bag (texas)";
nok $b !R(>=) $b, "Bag is reversed superset of itself (texas)";
ok $b !R(>=) $s, "Bag is not a reversed superset of Set (texas)";

ok $s !R(>=) $bh, "Set is not a reversed superset of BagHash (texas)";
nok $bh !R(>=) $bh, "BagHash is reversed superset of itself (texas)";
ok $bh !R(>=) $s, "BagHash is not a reversed superset of Set (texas)";

# is proper superset of

ok <your day> R⊃ $s, "'Your day' is reversed proper superset of Set";
nok $s R⊃ $s, "Set is not reversed proper superset of itself";
ok $s R⊃ <I'm afraid it isn't your day old chum>, "Set is reversed proper superset of string";

ok ($sh (-) set <is>) R⊃ $sh, "Set is reversed proper superset of SetHash";
nok $sh R⊃ $sh, "SetHash is not reversed proper superset of itself";
ok $sh R⊃ <I'm afraid it is my day>, "SetHash is reversed proper superset of string";

nok $s R⊃ $b, "Set is not a reversed proper superset of Bag";
nok $b R⊃ $b, "Bag is not reversed proper superset of itself";
nok $b R⊃ $s, "Bag is not a reversed proper superset of Set";

nok $s R⊃ $bh, "Set is not a reversed proper superset of BagHash";
nok $bh R⊃ $bh, "BagHash is not reversed proper superset of itself";
nok $bh R⊃ $s, "BagHash is not a reversed proper superset of Set";

ok <your day> R(>) $s, "'Your day' is reversed proper superset of Set";
nok $s R(>) $s, "Set is not reversed proper superset of itself";
ok $s R(>) <I'm afraid it isn't your day old chum>, "Set is reversed proper superset of string";

ok ($sh (-) set <is>) R(>) $sh, "Set is reversed proper superset of SetHash (texas)";
nok $sh R(>) $sh, "SetHash is not reversed proper superset of itself (texas)";
ok $sh R(>) <I'm afraid it is my day>, "SetHash is reversed proper superset of string (texas)";

nok $s R(>) $b, "Set is not a reversed proper superset of Bag (texas)";
nok $b R(>) $b, "Bag is not reversed proper superset of itself (texas)";
nok $b R(>) $s, "Bag is not a reversed proper superset of Set (texas)";

nok $s R(>) $bh, "Set is not a reversed proper superset of BagHash (texas)";
nok $bh R(>) $bh, "BagHash is not reversed proper superset of itself (texas)";
nok $bh R(>) $s, "BagHash is not a reversed proper superset of Set (texas)";

# is not a proper superset of

nok <your day> R⊅ $s, "'Your day' is reversed proper superset of Set";
ok $s R⊅ $s, "Set is not reversed proper superset of itself";
nok $s R⊅ <I'm afraid it isn't your day old chum>, "Set is reversed proper superset of string";

nok ($sh (-) set <is>) R⊅ $sh, "Set is reversed proper superset of SetHash";
ok $sh R⊅ $sh, "SetHash is not reversed proper superset of itself";
nok $sh R⊅ <I'm afraid it is my day>, "SetHash is reversed proper superset of string";

ok $s R⊅ $b, "Set is not a reversed proper superset of Bag";
ok $b R⊅ $b, "Bag is not reversed proper superset of itself";
ok $b R⊅ $s, "Bag is not a reversed proper superset of Set";

ok $s R⊅ $bh, "Set is not a reversed proper superset of BagHash";
ok $bh R⊅ $bh, "BagHash is not reversed proper superset of itself";
ok $bh R⊅ $s, "BagHash is not a reversed proper superset of Set";

nok <your day> !R(>) $s, "'Your day' is reversed proper superset of Set (texas)";
ok $s !R(>) $s, "Set is not reversed proper superset of itself (texas)";
nok $s !R(>) <I'm afraid it isn't your day old chum>, "Set is reversed proper superset of string (texas)";

nok ($sh (-) set <is>) !R(>) $sh, "Set is reversed proper superset of SetHash (texas)";
ok $sh !R(>) $sh, "SetHash is not reversed proper superset of itself (texas)";
nok $sh !R(>) <I'm afraid it is my day>, "SetHash is reversed proper superset of string (texas)";

ok $s !R(>) $b, "Set is not a reversed proper superset of Bag (texas)";
ok $b !R(>) $b, "Bag is not reversed proper superset of itself (texas)";
ok $b !R(>) $s, "Bag is not a reversed proper superset of Set (texas)";

ok $s !R(>) $bh, "Set is not a reversed proper superset of BagHash (texas)";
ok $bh !R(>) $bh, "BagHash is not reversed proper superset of itself (texas)";
ok $bh !R(>) $s, "BagHash is not a reversed proper superset of Set (texas)";

{
    my $a = set <Zeus Hera Artemis Apollo Hades Aphrodite Ares Athena Hermes Poseidon Hephaestus>;
    my $b = set <Jupiter Juno Neptune Minerva Mars Venus Apollo Diana Vulcan Vesta Mercury Ceres>;
    my $c = [<Apollo Arclight Astor>];
    my @d;

    is showset([∪] @d), showset(∅), "Union reduce works on nothing";
    is showset([∪] $a), showset($a), "Union reduce works on one set";
    is showset([∪] $a, $b), showset(set($a.keys, $b.keys)), "Union reduce works on two sets";
    is showset([∪] $a, $b, $c), showset(set($a.keys, $b.keys, $c.values)), "Union reduce works on three sets";

    is showset([(|)] @d), showset(∅), "Union reduce works on nothing (texas)";
    is showset([(|)] $a), showset($a), "Union reduce works on one set (texas)";
    is showset([(|)] $a, $b), showset(set($a.keys, $b.keys)), "Union reduce works on two sets (texas)";
    is showset([(|)] $a, $b, $c), showset(set($a.keys, $b.keys, $c.values)), "Union reduce works on three sets (texas)";

    is showset([∩] @d), showset(∅), "Intersection reduce works on nothing";
    is showset([∩] $a), showset($a), "Intersection reduce works on one set";
    is showset([∩] $a, $b), showset(set("Apollo")), "Intersection reduce works on two sets";
    is showset([∩] $a, $b, $c), showset(set("Apollo")), "Intersection reduce works on three sets";

    is showset([(&)] @d), showset(∅), "Intersection reduce works on nothing (texas)";
    is showset([(&)] $a), showset($a), "Intersection reduce works on one set (texas)";
    is showset([(&)] $a, $b), showset(set("Apollo")), "Intersection reduce works on two sets (texas)";
    is showset([(&)] $a, $b, $c), showset(set("Apollo")), "Intersection reduce works on three sets (texas)";
}

# RT #117997
{
    throws-like 'set;', Exception,
        'set listop called without arguments dies (1)',
        message => { m/'Function "set" may not be called without arguments'/ };
    throws-like 'set<a b c>;', X::Syntax::Confused,
        'set listop called without arguments dies (2)',
        message => { m/'Use of non-subscript brackets after "set" where postfix is expected'/ };
}

# vim: ft=perl6
