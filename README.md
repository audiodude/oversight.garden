## Oversight.garden

Collecting the oversight community's work in one place.

A small website at [oversight.garden](https://oversight.garden).

### Getting started

Oversight.garden is primarily a **Node** application, and uses **Ruby** for some data manipulation tasks.

Elasticsearch is used for text search and as a primary datastore.

#### Installing dependencies

* Install [Node](https://nodejs.org/) version 4.x or higher.
* Install [Elasticsearch](https://elastic.co) version 2.1 or higher.
* Install [Ruby](https://www.ruby-lang.org/en/) 2.2 or higher.
* Then install Ruby dependencies:

```
gem install bundler
bundle install
```

* And Node dependencies:

```
npm install
```

#### Working with the CSS

This project uses Sass, Bourbon, and Neat to develop front-end CSS.

Have Sass "watch" the `.scss` files with:

```
make watch
```

This will automatically detect changes to `/public/scss/main.scss` and re-compile to `/public/css/main.css`.

#### Setting up the data

Symlink a `data` dir that points to the location of your downloaded inspector general report data from the [unitedstates/inspectors-general](https://github.com/unitedstates/inspectors-general) project.

```
ln -s /path/to/ig/data data
```

Then copy the config example file:

```
cp config/config.yaml.example config/config.yaml
```

You probably don't need to make any changes to `config.yaml`. It looks for Elasticsearch at `http://localhost:9200` by default, and for IG report data in the `data` directory you symlinked above.

#### Running the app

Launch the app:

```
node app
```

Then visit the application at `http://localhost:3000`. It should work! But you won't see any data in it.

#### Loading app data

Once, **before the first time you load data**, you need to tell Elasticsearch to optimize loaded report text for efficient highlighting.

Use `rake` (which ships with Ruby) to run:

```
rake elasticsearch:init
```

You can add `force=true` to the end of the command to empty the database and reload the mappings.

Then, to actually load report data, run:

```
node tasks/inspectors.js
```

This defaults to loading every report for the current year. See [the full list of supported options](tasks/inspectors.js) for data loading.

If this all worked, you should be up and running!

### Git hooks

If you're contributing to the project, you can run the same syntax checks locally that would get run on Travis. Once you have cloned the project, run `tasks/install-git-hooks.sh`. This will create a symbolic link at `.git/hooks/pre-commit` that points to `tasks/pre-commit`.

From then on, Git will execute syntax checks whenever you run `git commit`. If there is an issue, the script will abort the commit and print an error message. If you need to bypass the syntax checks for any reason, use `git commit --no-verify`.

### Sitemap

Sitemaps can be generated with the following rake task:

```
rake sitemap:generate
```

### Public domain

This project is [dedicated to the public domain](LICENSE). As spelled out in [CONTRIBUTING](CONTRIBUTING.md):

> The project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](http://creativecommons.org/publicdomain/zero/1.0/).

> All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are agreeing to comply with this waiver of copyright interest.
