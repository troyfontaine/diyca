# Do-It-Yourself Certificate Authority

## OVERVIEW

This project provides a "Do-It-Yourself" (DIY) Certificate Authority (hence the name, diyca).  It was intended originally for use by developers when performing unit testing, but this fork is intended to allow it to function in a homelab environment when used in conjunction with other tooling to streamline the install and set up of this project.

To simplify the process of requesting a certificate, this project provides a Flask-based web ui to obtain X.509 certificates signed by the included Certificate Authority (CA).  The user simply needs provide a properly configured Certificate Signing Request (CSR) and visit the provided web page by this project hosted on an internal device, such as a Raspberry Pi.

## WHY

### UNIT TESTING

The inspiration for this project is the myriad of Internet of Things (IoT) projects that might be falling into one of the following categories of undesirable patterns:

* No data security at all: (1) no authentication of the endpoints, (2) no message integrity checking, and (3) data is transmitted over the network in cleartext.
* Partners are using weak cryptography (E.g. RC4 or Single-DES) and there is no secure methodology of installing or managing the secret keys.  E.g. coding the secret keys as program constants.
* Partners are using strong secret key cryptography but there is no secure methodology of installing or managing the secret keys.  E.g. The secret keys are never changed.

### HOMELAB

A lot of equipment available to Homelabbers is often old-meaning it may not come with support for things like TLS 1.0 or newer or requires a SHA-1 certificate due to the vendor not seeing a need when a devices was originally in development to give it anything more (or maybe it simply doesn't have the processing power to handle more).

This project allows a Homelabber to easily generate new certificates without a lot of fuss and to at least have some protection (even if it only means they get some experience with SSL/TLS and it doesn't protect much at all).

### EXPERIENCE

The original project's creator, [Richard Elkins](https://github.com/texadactyl) provided some great reasons for its inception:

```text
Even when developers agree to securely use public key infrastructure and strong cryptography, I have seen cases where they stub this aspect out of their project during unit testing.  This just puts off the inevitable and may cause project delays when the stubs are later replaced with operational code.  Better to design and develop a project from the very beginning as it is intended to be in production.

Therefore, the primary goal of this project is to allow developers to unit test programs which make use of X.509 certificate based authentication and cryptography.  Thus, when it is time to migrate to more stringent testing environments (E.g. integrated system testing and user acceptance testing), the only thing new will be the target environment details since the developers will have gained experience with a Certificate Authority operations, X.509 certificates, and managing the user's private key.
```

## PLATFORM

This project can be ran on either an x86/AMD64 (Modern AMD or Intel-based system) or ARMHF (Raspberry Pi or similar hobby board) platforms.

## LICENSING

This is *NOT* commercial software; instead, usage is covered by the GNU General Public License version 3 (2007).  In a nutshell, please feel free to use the project and share it as you will but please don't sell it.  Thanks!

See the LICENSE file for the GNU licensing information.

## GETTING STARTED

This and proper documentation are a work in progress-please bear with us!

Subfolders:

* app_web - Python 2 source code for the web server running in a Flask infrastructure
            (see docs/preparation_notes.txt for references to all of the supporting software
            as well as how to install, test, etc.)
* bin - Bash scripts for setting up diyca and other tools
* calvin - Self-signed Certificate Authority
* certs - Calvin's certificate and the web server's certificate
* docs - project documentation (admittedly, skimpy at the moment)
* example.users - example SSL programs that use certificates signed by Calvin, "alice" and "bob"
* log - Holds all of the log files which cutoff at midnight; aged to keep a maximum of 10 files
* signer - uploaded CSRs (temporarily) and downloaded CRTs (accumulating, for the moment)

The starting point with this project is the docs/preparation_notes.txt file.  Just follow the instructions of this note.  No need to directly download from this github project.

## THANKS

Thank you to Richard Elkins for putting this together in the first place, it has provided a great starting point for this effort.

## ISSUES

Using this project?  Awesome!  Please submit any bug requests as an issue and feature requests should be submitted as a Pull Request.
