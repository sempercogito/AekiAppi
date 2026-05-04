# Flutter dev container for AekiAppi
#
# Based on the official Cirrus Labs Flutter image which ships with:
#   - Flutter SDK (stable channel)
#   - Dart SDK
#   - Android SDK + command-line tools
#   - Git, curl, unzip and other common utilities
#
# A non-root "vscode" user is added so the VS Code Dev Container extension can
# set up the workspace safely.

FROM ghcr.io/cirruslabs/flutter:stable

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

# Create a non-root user and grant passwordless sudo so flutter doctor
# can install additional components without prompting.
RUN apt-get update \
    && apt-get install -y --no-install-recommends sudo \
    && groupadd --gid "${USER_GID}" "${USERNAME}" \
    && useradd  --uid "${USER_UID}" --gid "${USER_GID}" -m "${USERNAME}" \
    && echo "${USERNAME} ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/"${USERNAME}" \
    && chmod 0440 /etc/sudoers.d/"${USERNAME}" \
    && rm -rf /var/lib/apt/lists/*

# Make the Flutter SDK writable by the new user (path may vary by image version).
RUN for dir in /sdks/flutter /home/flutter /opt/flutter; do \
        [ -d "$dir" ] && chown -R "${USERNAME}:${USERNAME}" "$dir" || true; \
    done

USER ${USERNAME}

# Pre-warm the Flutter tool so the first `flutter` command inside the container
# is fast.
RUN flutter precache --android --universal
