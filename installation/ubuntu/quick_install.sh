#!/usr/bin/env bash

function bailout() {
    echo "${1}: Exiting"
    exit $2
}

# Create application directory
/bin/mkdir /opt/patchserver || bailout "Unable to create /opt/patchserver" 1

# Move required application files
/bin/cp -r ../../{requirements.txt,patchserver} /opt/patchserver
/bin/cp ./{config.py,wsgi.py} /opt/patchserver

/bin/chown -R www-data:www-data /opt/patchserver

/bin/cp ./patchserver.service /etc/systemd/system || bailout "Unable to copy patchserver.service" 2
/bin/chown root:root /etc/systemd/system/patchserver.service
/bin/chmod 644 /etc/systemd/system/patchserver.service


# Create application virtual environment
/usr/bin/virtualenv -p python2.7 -q /usr/local/patchserver-venv || bailout "Unable to create virtual environment" 3

# Install Python dependencies
/usr/local/patchserver-venv/bin/pip install futures gunicorn -r /opt/patchserver/requirements.txt

# Enable and start the service
/bin/systemctl enable patchserver.service
/bin/systemctl start patchserver.service

# Verify the service has started
/bin/systemctl status patchserver.service
