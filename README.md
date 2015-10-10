
## Purpose

This script analyzes issues of modules listed in
[Perl 6 Ecosystem](https://github.com/perl6/ecosystem/) repository and
[modules.perl6.org](http://modules.perl6.org/)

* Tells how many modules are listed in ecosystem's `META.list` and how many
are on the website
* Checks validity of JSON of every distro's meta file
* Checks if any ecosystem's entries point to distros with the same name
* Announces any modules listed in ecosystem but not listed on the website

## Installation

You'll need Perl 5 and `Mojo::UserAgent` and `JSON::Meth` modules:

    cpanm Mojo::UserAgent JSON::Meth

## Usage

Just run `modules-checker.pl` file included in this repo:

    perl modules-checker.pl

## Sample output:

```bash
$ perl test.pl
modules.perl6.org currently list 383 modules
Found 389 modules listed in ecosystem. Going to fetch each one (this will take a while)
https://raw.githubusercontent.com/FROGGS/p6-Foo-v1.2.0/master/META.info has the same name [Foo] as https://raw.githubusercontent.com/FROGGS/p6-Foo-v1.0.0/master/META.info!

JSON decode error while doing https://raw.githubusercontent.com/Leont/yamlish/master/META.info

https://raw.githubusercontent.com/tokuhirom/p6-HTTP-MultiPartParser/master/META6.json [HTTP::MultiPartParser] not found on modules.perl6.org!

https://raw.githubusercontent.com/tokuhirom/p6-Cookie-Baker/master/META6.json [Cookie::Baker] not found on modules.perl6.org!

https://raw.githubusercontent.com/tokuhirom/p6-HTTP-Parser/master/META6.json [HTTP::Parser] not found on modules.perl6.org!

https://raw.githubusercontent.com/stmuk/p6-eco-readme/master/META.info [App::ecoreadme] not found on modules.perl6.org!

All done!
```