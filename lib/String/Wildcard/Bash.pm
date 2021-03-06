package String::Wildcard::Bash;

use 5.010001;
use strict;
use warnings;

our $VERSION = '0.02'; # VERSION

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
                       contains_wildcard
               );

# note: order is important here, brace encloses the other
my $re1 =
    qr(
          # non-escaped brace expression, with at least one comma
          (?P<brace>
              (?<!\\)(?:\\\\)*\{
              (?:           \\\\ | \\\{ | \\\} | [^\\\{\}] )*
              (?:, (?:  \\\\ | \\\{ | \\\} | [^\\\{\}] )* )+
              (?<!\\)(?:\\\\)*\}
          )
      |
          # non-escaped brace expression, to catch * or ? or [...] inside so
          # they don't go to below pattern, because bash doesn't consider them
          # wildcards, e.g. '/{et?,us*}' expands to '/etc /usr', but '/{et?}'
          # doesn't expand at all to /etc.
          (?P<braceno>
              (?<!\\)(?:\\\\)*\{
              (?:           \\\\ | \\\{ | \\\} | [^\\\{\}] )*
              (?<!\\)(?:\\\\)*\}
          )
      |
          (?P<class>
              # non-empty, non-escaped character class
              (?<!\\)(?:\\\\)*\[
              (?:  \\\\ | \\\[ | \\\] | [^\\\[\]] )+
              (?<!\\)(?:\\\\)*\]
          )
      |
          (?P<joker>
              # non-escaped * and ?
              (?<!\\)(?:\\\\)*[*?]
          )
      )ox;

sub contains_wildcard {
    my $str = shift;

    while ($str =~ /$re1/go) {
        my %m = %+;
        return 1 if $m{brace} || $m{class} || $m{joker};
    }
    0;
}

1;
# ABSTRACT: Bash wildcard string routines

__END__

=pod

=encoding UTF-8

=head1 NAME

String::Wildcard::Bash - Bash wildcard string routines

=head1 VERSION

This document describes version 0.02 of String::Wildcard::Bash (from Perl distribution String-Wildcard-Bash), released on 2015-01-03.

=head1 SYNOPSIS

    use String::Wildcard::Bash qw(contains_wildcard);

    say 1 if contains_wildcard(""));      # -> 0
    say 1 if contains_wildcard("ab*"));   # -> 1
    say 1 if contains_wildcard("ab\\*")); # -> 0

=head1 DESCRIPTION

=for Pod::Coverage ^(qqquote)$

=head1 FUNCTIONS

=head2 contains_wildcard($str) => bool

Return true if C<$str> contains wildcard pattern. Wildcard patterns include C<*>
(meaning zero or more characters), C<?> (exactly one character), C<[...]>
(character class), C<{...,}> (brace expansion). Can handle escaped/backslash
(e.g. C<foo\*> does not contain wildcard, it's C<foo> followed by a literal
asterisk C<*>).

Aside from wildcard, bash does other types of expansions/substitutions too, but
these are not considered wildcard. These include tilde expansion (e.g. C<~>
becomes C</home/alice>), parameter and variable expansion (e.g. C<$0> and
C<$HOME>), arithmetic expression (e.g. C<$[1+2]>), history (C<!>), and so on.

Although this module has 'Bash' in its name, this set of wildcards should be
applicable to other Unix shells. Haven't checked completely though.

=head1 SEE ALSO

L<Regexp::Wildcards> to convert a string with wildcard pattern to equivalent
regexp pattern. Can handle Unix wildcards as well as SQL and DOS/Win32. As of
this writing (v1.05), it does not handle character class (C<[...]>) and
interprets brace expansion differently than bash.

Other C<String::Wildcard::*> modules.

=head1 HOMEPAGE

Please visit the project's homepage at L<https://metacpan.org/release/String-Wildcard-Bash>.

=head1 SOURCE

Source repository is at L<https://github.com/perlancar/perl-String-Wildcard-Bash>.

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website L<https://rt.cpan.org/Public/Dist/Display.html?Name=String-Wildcard-Bash>

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

perlancar <perlancar@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by perlancar@cpan.org.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
