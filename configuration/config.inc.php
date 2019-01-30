

/* Local configuration for Roundcube Webmail */
// ----------------------------------
// SYSTEM
// ----------------------------------
$config['enable_installer'] = false;

// Name your service. This is displayed on the login screen and in the window title
$config['product_name'] = 'Webmail SENE-NET';

// ----------------------------------
// SQL DATABASE
// ----------------------------------
// Database connection string (DSN) for read+write operations
// Format (compatible with PEAR MDB2): db_provider://user:password@host/database
// Currently supported db_providers: mysql, pgsql, sqlite, mssql, sqlsrv, oracle
// For examples see http://pear.php.net/manual/en/package.database.mdb2.intro-dsn.php
// NOTE: for SQLite use absolute path (Linux): 'sqlite:////full/path/to/sqlite.db?mode=0646'
//       or (Windows): 'sqlite:///C:/full/path/to/sqlite.db'
//$config['db_dsnw'] = 'pgsql://roundcube:roundcube@localhost/roundcube';

// you can define specific table (and sequence) names prefix
$config['db_prefix'] = 'rc';

// log driver:  'syslog', 'stdout' or 'file'.
//$config['log_driver'] = 'syslog';

// ----------------------------------
// IMAP
// ----------------------------------
// The IMAP host chosen to perform the log-in.
// Leave blank to show a textbox at login, give a list of hosts
// to display a pulldown menu or set one host as string.
// To use SSL/TLS connection, enter hostname with prefix ssl:// or tls://
// Supported replacement variables:
// %n - hostname ($_SERVER['SERVER_NAME'])
// %t - hostname without the first part
// %d - domain (http hostname $_SERVER['HTTP_HOST'] without the first part)
// %s - domain name after the '@' from e-mail address provided at login screen
// For example %n = mail.domain.tld, %t = domain.tld
// WARNING: After hostname change update of mail_host column in users table is
//          required to match old user data records with the new host.
$config['default_host'] = 'localhost';

// TCP port used for IMAP connections
//$config['default_port'] = 143;

// IMAP authentication method (DIGEST-MD5, CRAM-MD5, LOGIN, PLAIN or null).
// Use 'IMAP' to authenticate with IMAP LOGIN command.
// By default the most secure method (from supported) will be selected.
//$config['imap_auth_type'] = 'PLAIN';

// ----------------------------------
// SMTP
// ----------------------------------
$config['smtp_server'] = 'tls://sene.ovh';

// SMTP port (default is 587)
$config['smtp_port'] = 587;

// SMTP username (if required) if you use %u as the username Roundcube
// will use the current username for login
$config['smtp_user'] = '%u';

// SMTP password (if required) if you use %p as the password Roundcube
// will use the current user's password for login
$config['smtp_pass'] = '%p';

// SMTP AUTH type (DIGEST-MD5, CRAM-MD5, LOGIN, PLAIN or empty to use
// best server supported one)
//$config['smtp_auth_type'] = 'PLAIN';

//$config['smtp_conn_options'] = array(
//     'ssl' => array(
//       'verify_peer' => true,
//       // certificate is not self-signed if cafile provided
//       'allow_self_signed' => false,
//       // For Letsencrypt use the following two lines and remove the 'cafile' option above.
//       //'ssl_cert' => '/var/lib/acme/sene.ovh/fullchain.pem'
//       //'ssl_key'  => '/var/lib/acme/sene.ovh/key.pem'
//       // probably optional parameters
//       'ciphers' => 'TLSv1+HIGH:!aNull:@STRENGTH',
//       'peer_name' => 'mail.sene.ovh',
//     ),
// );

// ----------------------------------
// provide an URL where a user can get support for this Roundcube installation
// PLEASE DO NOT LINK TO THE ROUNDCUBE.NET WEBSITE HERE!
$config['support_url'] = 'https://sene.ovh';

// use this folder to store log files
// must be writeable for the user who runs PHP process (Apache user if mod_php is being used)
// This is used by the 'file' log driver.
$config['log_dir'] = '/tmp/';

// use this folder to store temp files
// must be writeable for the user who runs PHP process (Apache user if mod_php is being used)
$config['temp_dir'] = '/tmp/';

// This key is used for encrypting purposes, like storing of imap password
// in the session. For historical reasons it's called DES_key, but it's used
// with any configured cipher_method (see below).
$config['des_key'] = 'JZUH4FTsIUJJE4l6J5CTZeKz';

// Encryption algorithm. You can use any method supported by openssl.
// Default is set for backward compatibility to DES-EDE3-CBC,
// but you can choose e.g. AES-256-CBC which we consider a better choice.
$config['cipher_method'] = 'AES-256-CBC';

// Automatically add this domain to user names for login
// Only for IMAP servers that require full e-mail addresses for login
// Specify an array with 'host' => 'domain' values to support multiple hosts
// Supported replacement variables:
// %h - user's IMAP hostname
// %n - hostname ($_SERVER['SERVER_NAME'])
// %t - hostname without the first part
// %d - domain (http hostname $_SERVER['HTTP_HOST'] without the first part)
// %z - IMAP domain (IMAP hostname without the first part)
// For example %n = mail.domain.tld, %t = domain.tld
$config['username_domain'] = '%d';

// Message size limit. Note that SMTP server(s) may use a different value.
// This limit is verified when user attaches files to a composed message.
// Size in bytes (possible unit suffix: K, M, G)
//$config['max_message_size'] = '25M';

// ----------------------------------
// PLUGINS
// ----------------------------------
// List of active plugins (in plugins/ directory)
//$config['plugins'] = array('archive', 'attachment_reminder', 'autologon', 'emoticons', 'enigma', 'filesystem_attachments', 'help', 'identicon', 'identity_select', 'jqueryui', 'managesieve', 'newmail_notifier', 'password', 'show_additional_headers', 'subscriptions_option', 'virtuser_file', 'zipdownload');

// the default locale setting (leave empty for auto-detection)
// RFC1766 formatted language name like en_US, de_DE, de_CH, fr_FR, pt_BR
$config['language'] = 'fr_FR';

// Make use of the built-in spell checker. It is based on GoogieSpell.
$config['enable_spellcheck'] = false;

// Set the spell checking engine. Possible values:
// - 'googie'  - the default (also used for connecting to Nox Spell Server, see 'spellcheck_uri' setting)
// - 'pspell'  - requires the PHP Pspell module and aspell installed
// - 'enchant' - requires the PHP Enchant module
// - 'atd'     - install your own After the Deadline server or check with the people at http://www.afterthedeadline.com before using their API
// Since Google shut down their public spell checking service, the default settings
// connect to http://spell.roundcube.net which is a hosted service provided by Roundcube.
// You can connect to any other googie-compliant service by setting 'spellcheck_uri' accordingly.
$config['spellcheck_engine'] = 'googie';

// Encoding of long/non-ascii attachment names:
// 0 - Full RFC 2231 compatible
// 1 - RFC 2047 for 'name' and RFC 2231 for 'filename' parameter (Thunderbird's default)
// 2 - Full 2047 compatible
$config['mime_param_folding'] = 0;

// If true all folders will be checked for recent messages
$config['check_all_folders'] = true;

// ----------------------------------
// USER PREFERENCES
// ----------------------------------
// Use this charset as fallback for message decoding
$config['default_charset'] = 'UTF-8';

// skin name: folder from skins/
$config['skin'] = 'larry';

// Default messages listing mode. One of 'threads' or 'list'.
$config['default_list_mode'] = 'threads';

// prefer displaying HTML messages
$config['prefer_html'] = true;

// compose html formatted messages by default
//  0 - never,
//  1 - always,
//  2 - on reply to HTML message,
//  3 - on forward or reply to HTML message
//  4 - always, except when replying to plain text message
$config['htmleditor'] = 1;

// Default font for composed HTML message.
// Supported values: Andale Mono, Arial, Arial Black, Book Antiqua, Courier New,
// Georgia, Helvetica, Impact, Tahoma, Terminal, Times New Roman, Trebuchet MS, Verdana
$config['default_font'] = 'Tahoma';
// Default font size for composed HTML message.
// Supported sizes: 8pt, 10pt, 12pt, 14pt, 18pt, 24pt, 36pt
$config['default_font_size'] = '10pt';

// save compose message every 300 seconds (5min)
$config['draft_autosave'] = 60;

// save copies of compose messages in the browser's local storage
// for recovery in case of browser crashes and session timeout.
$config['compose_save_localstorage'] = true;

// Set true to Mark deleted messages as read as well as deleted
// False means that a message's read status is not affected by marking it as deleted
$config['read_when_deleted'] = true;

// display remote resources (inline images, styles)
// 0 - Never, always ask
// 1 - Ask if sender is not in address book
// 2 - Always allow
$config['show_images'] = 1;

// Interface layout. Default: 'widescreen'.
//  'widescreen' - three columns
//  'desktop'    - two columns, preview on bottom
//  'list'       - two columns, no preview
$config['layout'] = 'widescreen';

// When replying:
// -1 - don't cite the original message
// 0  - place cursor below the original message
// 1  - place cursor above original message (top posting)
// 2  - place cursor above original message (top posting), but do not indent the quote
$config['reply_mode'] = 2;

// When replying strip original signature from message
$config['strip_existing_sig'] = true;

// Place replies in the folder of the message being replied to
$config['reply_same_folder'] = false;

// Default behavior of Reply-All button:
// 0 - Reply-All always
// 1 - Reply-List if mailing list is detected
$config['reply_all_mode'] = 0;

// Show signature:
// 0 - Never
// 1 - Always
// 2 - New messages only
// 3 - Forwards and Replies only
$config['show_sig'] = 1;

// By default the signature is placed depending on cursor position (reply_mode).
// Sometimes it might be convenient to start the reply on top but keep
// the signature below the quoted text (sig_below = true).
$config['sig_below'] = false;

// Enables adding of standard separator to the signature
$config['sig_separator'] = true;

// 0 - Do not expand threads
// 1 - Expand all threads automatically
// 2 - Expand only threads with unread messages
$config['autoexpand_threads'] = 2;

// show pretty dates as standard
$config['prettydate'] = true;

// open messages in new window
$config['message_extwin'] = false;

// open message compose form in new window
$config['compose_extwin'] = false;

// show up to X items in messages list view
$config['mail_pagesize'] = 100;

// show up to X items in contacts list view
$config['addressbook_pagesize'] = 100;

// sort contacts by this col (preferably either one of name, firstname, surname)
$config['addressbook_sort_col'] = 'firstname';

// Clear Trash on logout
$config['logout_purge'] = false;
