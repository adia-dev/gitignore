# Gitignore

## Description

Gitignore Script is a simple bash script to generate a .gitignore file for your project using the gitignore.io API. The script allows you to generate a gitignore file for specific languages, frameworks, or libraries, as well as use a custom template for the file.

The project is still in its early stages, so there are still a lot of features to be added. If you have any suggestions, feel free to open an issue or submit a pull request.

## Installation

To install the script, download it and move it to the installation directory:

```bash
$ sudo wget https://raw.githubusercontent.com/adia-dev/gitignore-script/main/gitignore.sh -O /usr/local/bin/gitignore
$ sudo chmod +x /usr/local/bin/gitignore
```

## Usage

Run the script with the following command:

```bash
$ gitignore [options] [languages]
```

### Options

| Option          | Description                                                       |
| --------------- | ----------------------------------------------------------------- |
| -h, --help      | Show help message                                                 |
| -v, --version   | Show script version                                               |
| -l, --list      | List all available languages, frameworks, and libraries           |
| -t, --template  | Use a template for the gitignore file                             |
| -o, --overwrite | Overwrite the template if it already exists                       |
| -a, --append    | Append to the existing gitignore file                             |
| -p, --path      | Specify the path to the gitignore file                            |
| -V, --verbose   | Show verbose output                                               |
| -u, --uninstall | Uninstall the script and all its related files                    |
| -i, --install   | Install the script binary and make it available globally          |
| -c, --clean     | Clean the cache of the script                                     |
| -s, --silent    | Do not show any output                                            |
| -f, --force     | Force the script to run even if the gitignore file already exists |
| -d, --debug     | Show debug output                                                 |
| -t, --template  | Use a template for the gitignore file                             |

### Examples

```bash
# Generate a gitignore file for the languages C, C++, and Rust
$ gitignore c,c++,rust

# Generate a gitignore file for Node.js, MacOS, and Visual Studio Code
$ gitignore node,macos,visualstudiocode

# List all available languages, frameworks, and libraries
$ gitignore -l

# Search for a specific language, framework, or library
$ gitignore -l | grep python

# Create a template for the languages C, C++, and Rust
$ gitignore -t c_cpp_rust c,c++,rust

# Use the template c_cpp_rust to generate a gitignore file
$ gitignore -t c_cpp_rust

# Overwrite the template c_cpp_rust if it already exists
$ gitignore -t c_cpp_rust -o

# Use a template as well as specify languages
$ gitignore -t c_cpp_rust c,c++,rust
```

## Other options

The script provides other options that can be used to install, uninstall, and clean the script. These options are not meant to be used by the user, but are used by the script itself.

| Option          | Description                                              |
| --------------- | -------------------------------------------------------- |
| -i, --install   | Install the script binary and make it available globally |
| -u, --uninstall | Uninstall the script and all its related files           |
| -c, --clean     | Clean the cache of the script                            |
| -d, --debug     | Show debug output                                        |
| -s, --silent    | Do not show any output                                   |

## Copyrigth

I do not own the gitingore.io API. All rights belong to the owner of the API.
Please check their [GitHub repository](https://github.com/toptal/gitignore.io) for more information.

## License

This script is licensed under the MIT License. Please check the LICENSE file for more information.

## Author

This script was written by adia-dev. Please check my [GitHub profile](https://github.com/adia-dev) for more projects, you can also contact me on discord where I am quite active: adia#3344

## Contributing

Thank you for your interest in contributing to our project! We welcome all contributions, including bug fixes and new features.
Please check the [CONTRIBUTING](https://github.com/adia-dev/gitignore/blob/main/CONTRIBUTING) file for more information.

## Code of Conduct

Please note that our project has a [Code of Conduct](https://github.com/adia-dev/gitignore/blob/main/CODE_OF_CONDUCT). We expect all contributors to adhere to its guidelines.

## Acknowledgements

- [gitingore.io](https://github.com/toptal/gitignore.io) - For the gitignore.io API

## Disclaimer

This script is not affiliated with gitingore.io in any way. All rights belong to the owner of the API.

## Support

If you like this project, please consider supporting it by giving it a star on GitHub. It really helps!

## Contact

As stated above, you can contact me on discord where I am quite active: adia#3344
