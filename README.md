# Doccer

Doccer is a very simple command-line reference manager, and is **currently a work in progress**. The name is a pun on [Docker](https://www.docker.com) (don't sue me, please) and "document".

It stores all entries as a .json file at `~/.doccer/doccer-library.json`. This library can be exported to .bibtex format (see [Usage](#Usage)).

Currently supported fields are:

- Title
- Year
- Journal
- Folder (zero or one, for organizational purposes)
- Tags (zero or more, for organizational purposes) (should be comma-seperated, see [Usage](#usage))
- Publisher
- Type (see [Bibtex Entry Types](https://www.bibtex.com/e/entry-types/))

Pre-1.0 to-dos include:

- [x] Removing items
- [ ] Naive text search support
- [ ] Field text search support
- [ ] Field regex search support
- [x] Support Bibtex types other than `article`
- [ ] Bibtex import support
- [ ] Other import formats
- [ ] Other export formats

There is no official roadmap as of yet (and there probably never will be).

## Installation

Ensure you have [Elixir](https://elixir-lang.org) installed (I am using `1.11.0`), then clone the repository and run `mix deps.get && mix escript.build` to create a `doccer` executable, which you can run using `./doccer`.

## Usage

Add an item to your library:

```
doccer add --author "David Graeber" --year "2015" --title "The Utopia of Rules: On Technology, Stupidity, and the Secret Joys of Bureaucracy"
```

With a folder and tags:

```
doccer add --author "David Graeber" --year "2015" --folder "Social Theory" --tags "Bureaucracy, anthopology"
```

Remove all items matching a given field from the library (case-insensitive):

```
doccer remove --author "Ayn Rand"
```

Export the library as bibtex to stdout:

```
doccer export
```

Export the library as bibtex, and copy to clipboard (currently only macOS is supported, please open an issue if you are on another platform):

```
doccer export --copy
```

## License

Doccer is licensed under the GNU General Public License Version 3 (see [LICENSE](https://gitlab.com/Niek_pas/doccer-elixir/-/blob/master/LICENSE)). In short, this means you can do whatever you want with this, as long as you ensure others can, in turn, do whatever they want to do with _your_ work. It also ensures I am not liable if you accidentally nuke your entire reference library (please [back up your files](http://5by5.tv/hypercritical/2)).
