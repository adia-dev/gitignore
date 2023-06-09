gitignore Command Manual

Usage: gitignore [options] [languages/frameworks/libraries,...]

If no argument is provided, a default gitignore file will be generated.

To generate a gitignore file for specific languages, frameworks or libraries, provide their names as comma-separated arguments.

Example: gitignore -o my_gitignore_file node,react,angular,django

Options:

-o, --output FILENAME Specify the output filename for the generated gitignore file. The default is \.gitignore\.

-a, --append Append to the existing gitignore file instead of overwriting it.

-h, --help Show this help message and exit.

-l, --list Show the list of available languages/frameworks/libraries and exit.

-t, --template NAME Use a custom template from the ~/.gitignore.io/templates directory if it exists, if not it'll create it with the specified languages/frameworks/libraries.
If no template name is specified, the default template will be used.
To overrite an existing template, use the -o or --overwrite-template option.

-c, --clear-cache Clear the local list of languages/frameworks/libraries.

-i, --install Install the script in the /usr/local/bin directory.

-v, --version Show the version information and exit.

-u, --uninstall Uninstall the script from the /usr/local/bin directory.

--verbose Show more information about what the script is doing.

Example of available languages/frameworks/libraries:

- node
- react
- rust
- c++
- rails
- laravel
- wordpress
- drupal
- visualstudiocode
- macos
- ...

To see this manual again, use the -h or --help option.
To see the latest list of available languages/frameworks/libraries, use the -l or --list option.
To clear the local list of languages/frameworks/libraries, use the -c or --clear-cache option.
To see the version information, use the -v or --version option.

Visit my GitHub repository for more information: https://github.com/adia-dev/gitignore
Thanks to gitignore.io for providing the list of languages/frameworks/libraries.
Visit them at: https://github.com/toptal/gitignore.io
