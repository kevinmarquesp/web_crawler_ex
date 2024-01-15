

> [!CAUTION]
> Some URLs can throw a **timeout error** due to the `:httpoison` behavior, when it happens -- even it's running inside a parallel task -- it halts the whole program execution.  I'm using this project idea to study and learn Elixir, so I **didn't handle all errors** properly yet!

# WebCrawlerEx <sup>*`under development`*</sup>
Tool to extract all the anchor links URLs of websites, store that list of URLs inside a SQLite3 database and repeat that same process to each link recursively using multiple sub process in parallel. This project is meat to be an helper tool that you can use to work in other projects that is related to the web, useful when you need a list full of non-repeated valid URLs to extract their body content or something like that. Hope you enjoy this project. 😊

List of **dependencies** to run:
+ Elixir `1.16.0` or higher
+ Mix `1.16.0` or higher

Useful packages to have:
+ Git, to clone this repository more easily
+ SQLite3 command line utility, to check the generated database file

## Basic Usage
After you've cloned this repository to your machine and installed all the dependencies with **`mix deps.get`**, you'll  to run the `WebCrawlerEx/1` function. This function accepts only one argument and it should be an list of strings, each string being the base URL to start crawling the others[^1].
[^1]: Little side note: the URLs that you pass **will not** be stored at the database file!

Usage examples:
```bash
mix run -e 'WebCrawlerEx.main(["wikkipedia.org"])'                #staring with just a single website
mix run -e 'WebCrawlerEx.main(["wikipedia.org", "example.com"])'  #passing multiple websites
mix run -e 'WebCrawlerEx.main([])'                                #nothing happens...
```

> [!TIP]
> If you're in a Linux system, you can run the `web_crawler_ex` script helper and pass the websites that you want to crawl as simple arguments, like every good command line utility

### Notes About This Project
+ As you saw on the examples, if the list is empty the code will do nothing besides creating the database file
+ This program only fetch URLs of `<a>>` tags **that is inside** the `<body>` tag
	+ It just ignore local non HTTP links tho -- like, if an page links to `/about` instead of `https://example.com/about`, it will be just ignored
+ If an webpage doesn't has any `<a>` tags, the program will warn you on the standard output
+ Each process will display the on the standard output the URL that it's handling at the moment, before writing to the database table

## Development Notes & Roadmap
This code is just an **prototype**, it will be improved soon. The main problem of this approach is that even if a link is already registered on the SQLite3 table, it will try to assign it again making the code slow, and -- of course -- writing code without handling the possible errors is a bad practice.

### Project's TODOS
+ [ ] :art: **style**: refactor the code and put the other modules in their own files
+ [ ] :bug: **bug**: rewrite the whole project to handle the `:httpoison` request errors
+ [ ] :sparkles: **feature**: list all the valid URLs of an page with REGEX (even outside the body)
+ [ ] :sparkles: **feature**: convert the local URL links to full HTTP URL links, with a little help from the `:floki` library
+ [ ] :art: **style**: create an wrapper function that executes a lambda function for each item in a list
