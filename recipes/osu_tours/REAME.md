# OSU Tours

## Creating/Importing Tours
Ensure that the Dependencies for tours are listed as an empty object
e.g.
```yaml
dependencies: { }
```

Ensure that any empty selectors are fully blank, remove quotes.

## Installing/Applying
Ensure the terminal session is in the web root of drupal then run
```shell
drush recipe ../recipies/osu_tours
```

## Updating Tours
If the tour is changing from what is imported, it needs to be deleted first before the updated version can be imported
via recipes. See [Drupal Issue 3475693](https://www.drupal.org/project/drupal/issues/3475693)
