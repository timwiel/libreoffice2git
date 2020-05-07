# libreoffice2git
A bashscript to convert Libreoffice Writer Documents (.odt) to a Git Friendly Format with text based diff available

## Preamble

Libreoffice file formats are ZIP archives with XML files in them containing the content and styles. As ZIP archives are binary files unfortunately Git (and therefore GitHub, GitLab,etc.) won't display a nice diff for them. 

This script provides a work-around in the meantime by creating a folder for each .ODT file and placing within it content that can easily have diff performed on it with good results.

## Features

- Creates a subfolder called <FILENAME.odt.git> in the folder the .odt file resides in
- Creates Markdown and Plaintext using pandoc
- Optionally:
  - Exports embeded pictures from the .odt file
  - Exports the whole "flat odt xml" file but tidies the XML using xmllint for easier comparisions

## Usage

```
USAGE: ./libreoffice2git.sh [-hpz] -i <file>

  where:
    -i  --input         Input file (.odt format)
    -p  --pictures      Extract the pictures
    -z  --unzip         Save the full unzipped ODT (includes -p)
    -h  --help          show this help text
```

Please note that this script requires unzip, pandoc and xmllint to be installed. These are easily installed on Mac (from Homebrew)(e.g. `brew install pandoc`) or Ubuntu (e.g. `apt-get install pandoc`)

## Examples

Extract just markdown and plaintext from resume.odt

```
./libreoffice2git.sh --input resume.odt
```

Extract just markdown and plaintext with pictures from resume.odt

```
./libreoffice2git.sh --pictures --input resume.odt
```

Flatten the .odt into xml, pictures with markdown and plaintext from resume.odt

```
./libreoffice2git.sh --pictures --unzip --input resume.odt
```

## Based on

This script is based on the powershell script for Microsoft Word .docx files by Tomáš Hübelbauer found at https://github.com/TomasHubelbauer/modern-office-git-diff