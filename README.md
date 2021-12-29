<p align="center">
<img src="https://haskellfoundation.github.io/static/images/logos/hf-logo-alpha.png" width="350" height="282" alt="Haskell Foundation" title="Haskell Foundation">
</p>

# The Haskell Foundation Website

[![Hackage](https://img.shields.io/static/v1?label=Haskell%20Foundation&message=official&color=purple&style=for-the-badge)](https://haskell.foundation)

This repository is for the [haskell.foundation](https://haskell.foundation) website. It is a proud, Hakyll-based site, built as an in-kind contribution from [Obsidian Systems](https://obsidian.systems), and maintained by the Haskell Foundation and its volunteers. If you would like to get started with a merge request, please consult the documentation below.

## Table Of Contents

- [The Haskell Foundation Website](#the-haskell-foundation-website)
  - [Table Of Contents](#table-of-contents)
  - [Building](#building)
  - [CI](#ci)
  - [License](#license)
  - [Dev Deployments List](https://github.com/haskellfoundation/haskellfoundation.github.io/blob/gh-pages/DEPLOYMENTS.md)

## Building

To build the project:

```bash
stack build
```

Once the project has built (which can take a while due to the dependencies for Hakyll), to generate the site use:

```bash
stack exec -- site build
```

The site will be build in the `_site` directory, and you can open the files in your browser of choice. Due to a Hakyll issue, some sponsor logos will not show up correctly. This is expected behavior, and should be fine for the deployed site.

For further information, please refer to the [CONTRIBUTING.md](CONTRIBUTING.md) at the root of this project.

## CI

We use GitHub Actions `.github/workflows/main.yml` to build the site for production.

The general steps are:

1. Check out the `hakyll` branch
2. Install Haskell
3. Restore the cached build artefacts
4. Build the `site` executable
5. Rebuild the site contents using the `site` executable
6. Check out the main branch
7. Copy the `_site` directory over the `main` branch contents
8. Commit and push the site contents to the `main` branch.

## License

This site is open source, and covered under the Apache 2.0 license.
