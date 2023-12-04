#!/bin/bash

USER=rueedlinger
REPO=autoencoder-tf
NBVIEWER_LINK="https://nbviewer.jupyter.org/github/$USER/$REPO/blob/master"

quit() {
    echo "Quit export notebook script!"
    exit 1
}

trap quit SIGINT SIGTERM

cleanup_md() {
    find "$DIR_NOTEBOOKS" -not -path '*/\.*' -name "*.md" -exec rm {} \;
}

remove_style() {
    find "$DIR_NOTEBOOKS" -not -path '*/\.*' -name "*.md" -exec sed -i '' '/<style.*>/,/<\/style>/d' {} \;
}

cleanup_images() {
    find "$DIR_NOTEBOOKS" -not -path '*/\.*' -name "*.png" -exec rm {} \;
}

export_notebooks() {
    for path in $(find "$DIR_NOTEBOOKS" -not -path '*/\.*' -name "*.ipynb"); do
        file=$(basename "$path")
        jupyter nbconvert --execute --to markdown "$path"
        newFile=${path//.ipynb/.md}
        echo -e ">**Note**: This is a generated markdown export from the Jupyter notebook file [$file]($file).\n>You can also view the notebook with the [nbviewer]($NBVIEWER_LINK/$path) from Jupyter. \n\n$(cat "$newFile")" > "$newFile"
    done
}

execute_notebooks() {
    for path in $(find "$DIR_NOTEBOOKS" -not -path '*/\.*' -name "*.ipynb"); do
        echo "Execute notebook ${path}"
        jupyter nbconvert --to notebook --inplace --execute "$path"
    done
}

DIR_NOTEBOOKS=notebooks
REMOVE_MARKDOWN=false
REMOVE_IMAGES=false
REMOVE_STYLE=false
EXPORT_NOTEBOOKS=true

while test $# -gt 0; do
    case "$1" in
        --no-export) EXPORT_NOTEBOOKS=false ;;
        --rm-md) REMOVE_MARKDOWN=true ;;
        --rm-images) REMOVE_IMAGES=true ;;
        --rm-style) REMOVE_STYLE=true ;;
        --dir) shift; DIR_NOTEBOOKS="$1" ;;
        --*) echo "Bad option $1"; exit 1 ;;
        *) echo "Bad option $1"; exit 1 ;;
    esac
    shift
done

echo "Export notebooks to markdown in directory: $DIR_NOTEBOOKS"

if $REMOVE_MARKDOWN; then
    echo "removing Markdown files..."
    cleanup_md
fi

if $REMOVE_IMAGES; then
    echo "removing image files..."
    cleanup_images
fi

if $REMOVE_STYLE; then
    echo "removing styles..."
    remove_style
fi

if $EXPORT_NOTEBOOKS; then
    echo "exporting notebooks..."
    export_notebooks
fi

echo "Script execution complete."