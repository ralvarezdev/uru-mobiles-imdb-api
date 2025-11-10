REM Create directory
mkdir kurrentdb\certs

REM Generate certificate (requires OpenSSL for Windows)
openssl req -x509 -newkey rsa:2048 -nodes ^
  -keyout kurrentdb\certs\node.key ^
  -out kurrentdb\certs\node.crt ^
  -days 3650 ^
  -subj "/CN=kurrentdb"

REM Verify files were created
dir kurrentdb\certs

# Create the kurrentdb-setup certs directory
mkdir kurrentdb-setup\certs

# Copy to kurrentdb-setup
copy .\kurrentdb\certs\node.key .\kurrentdb-setup\certs\node.key
copy .\kurrentdb\certs\node.crt .\kurrentdb-setup\certs\node.crt