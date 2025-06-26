#
# Kali Linux Headless Dockerfile - Optimized for Layer Caching
#
# Base Image: Kali Rolling
# Language: en_US.UTF-8 (English)
# Keyboard: Norwegian
#

# --- Base Image ---
# Every Dockerfile must start with a FROM instruction.
FROM kalilinux/kali-rolling

# --- Environment Configuration ---
# Set the frontend to noninteractive to prevent prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Set the system LANGUAGE to English
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# --- Installation Layers ---

# Layer 1: Update package lists. This only re-runs if the base image changes.
RUN apt-get update

# Layer 2: Install core dependencies & configure locales/keyboard.
# We now install 'keyboard-configuration' here, before we try to configure it.
RUN echo "keyboard-configuration keyboard-configuration/layoutcode string no" | debconf-set-selections && \
    apt-get -y install --no-install-recommends locales sudo keyboard-configuration && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# nb_NO.UTF-8 UTF-8/nb_NO.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    dpkg-reconfigure --frontend=noninteractive keyboard-configuration

# Layer 3: Install the main kali-linux-headless metapackage.
# This is the most time-consuming layer and is now isolated.
RUN apt-get -y install --no-install-recommends kali-linux-headless

# Layer 4: Install Network Tools
RUN apt-get -y install --no-install-recommends \
    iputils-ping \
    nmap \
    masscan \
    dnsutils \
    tcpdump \
    proxychains4 \
    netcat-traditional \
    socat \
    ligolo-ng

# Layer 5: Install Web Tools
RUN apt-get -y install --no-install-recommends \
    ffuf \
    gobuster \
    nikto \
    sqlmap

# Layer 6: Install Credential & Password Tools
RUN apt-get -y install --no-install-recommends \
    impacket-scripts \
    hashcat \
    john

# Layer 7: Install General Utilities & Final Cleanup
# We add 'wget' here to be able to download the config file later.
RUN apt-get -y install --no-install-recommends \
    git \
    tmux \
    unzip \
    fzf \
    wget \
    # Clean up apt cache after the final install
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


# --- Final Configuration ---

# Layer 8: Download user-specific configurations
RUN mkdir -p /root/.config/tmux && \
    wget -O /root/.config/tmux/tmux.conf https://raw.githubusercontent.com/ilostab/config/refs/heads/main/tmux.conf && \
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && \
    echo '[ -f /usr/share/doc/fzf/examples/key-bindings.bash ] && source /usr/share/doc/fzf/examples/key-bindings.bash' >> /root/.bashrc

# Set the default command to execute when the container starts
CMD ["/bin/bash"]

