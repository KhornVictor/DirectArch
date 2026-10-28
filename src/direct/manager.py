"""Core path shortcut manager with CRUD operations."""

import os
from pathlib import Path
from typing import Dict, Optional, Tuple
from direct.config import load_paths, save_paths


class PathManager:
    """Manages path aliases, directory resolutions, and configuration persistence."""

    def __init__(
        self,
        paths: Optional[Dict[str, str]] = None,
        config_path: Optional[Path] = None,
    ) -> None:
        """Initialize PathManager with paths and optional config file override."""
        self._config_path = config_path
        self._paths: Dict[str, str] = paths if paths is not None else load_paths()

    @property
    def paths(self) -> Dict[str, str]:
        """Return the dictionary of configured paths."""
        return self._paths

    def _find_key(self, name: str) -> Optional[str]:
        """Find the matching key regardless of case."""
        lookup = name.strip().lower()
        for key in self._paths:
            if key.lower() == lookup:
                return key
        return None

    def resolve(self, name: str, expand: bool = True) -> Optional[str]:
        """Resolve a shortcut name to its directory path. Case-insensitive."""
        matched_key = self._find_key(name)
        if matched_key is None:
            return None
        raw_path = self._paths[matched_key]
        if not expand:
            return raw_path
        # Keep Windows drive paths as is (e.g. C:\...)
        if len(raw_path) >= 2 and raw_path[0].isalpha() and raw_path[1] == ":":
            return raw_path
        # Expand user directory ~ and shell environment variables
        return os.path.expandvars(os.path.expanduser(raw_path))

    def list_paths(self) -> Dict[str, str]:
        """Return a copy of all registered paths."""
        return dict(self._paths)

    def exists(self, name: str) -> bool:
        """Check whether a shortcut key is defined."""
        return self._find_key(name) is not None

    def add(self, name: str, path: str, overwrite: bool = False) -> str:
        """Add a new path shortcut and persist to disk.

        Args:
            name: Shortcut identifier.
            path: Target directory path.
            overwrite: If False and shortcut exists, raises ValueError.

        Returns:
            The resolved target path.

        Raises:
            ValueError: If shortcut exists and overwrite is False.
        """
        clean_name = name.strip()
        if not clean_name:
            raise ValueError("Shortcut name cannot be empty.")

        existing_key = self._find_key(clean_name)
        if existing_key is not None and not overwrite:
            raise ValueError(
                f"Shortcut '{clean_name}' already exists (pointing to '{self._paths[existing_key]}')."
            )

        key_to_use = existing_key if existing_key is not None else clean_name
        self._paths[key_to_use] = path
        self.save()
        return path

    def update(self, name: str, path: str) -> str:
        """Update an existing path shortcut and persist to disk.

        Args:
            name: Shortcut identifier.
            path: New target directory path.

        Returns:
            The updated target path.

        Raises:
            KeyError: If shortcut does not exist.
        """
        clean_name = name.strip()
        existing_key = self._find_key(clean_name)
        if existing_key is None:
            raise KeyError(f"Shortcut '{clean_name}' does not exist.")

        self._paths[existing_key] = path
        self.save()
        return path

    def set(self, name: str, path: str) -> Tuple[str, bool]:
        """Create or update a path shortcut and persist to disk.

        Args:
            name: Shortcut identifier.
            path: Target directory path.

        Returns:
            Tuple of (path, was_updated) where was_updated is True if existing key was modified.
        """
        clean_name = name.strip()
        if not clean_name:
            raise ValueError("Shortcut name cannot be empty.")

        existing_key = self._find_key(clean_name)
        was_updated = existing_key is not None
        key_to_use = existing_key if existing_key is not None else clean_name

        self._paths[key_to_use] = path
        self.save()
        return path, was_updated

    def remove(self, name: str) -> str:
        """Remove an existing shortcut and persist to disk.

        Args:
            name: Shortcut identifier to remove.

        Returns:
            The previous directory path of the removed shortcut.

        Raises:
            KeyError: If shortcut does not exist.
        """
        clean_name = name.strip()
        existing_key = self._find_key(clean_name)
        if existing_key is None:
            raise KeyError(f"Shortcut '{clean_name}' not found.")

        old_path = self._paths.pop(existing_key)
        self.save()
        return old_path

    def save(self) -> Path:
        """Persist current paths to the configuration file."""
        return save_paths(self._paths, config_file=self._config_path)
