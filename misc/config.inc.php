// ----------------------------------
// SQL DATABASE
// ----------------------------------
$config['db_prefix'] = 'rc';

// ----------------------------------
// IMAP
// ----------------------------------
$config['default_host'] = 'tls://mail.%d';
$config['default_port'] = 143;
$config['imap_auth_type'] = 'PLAIN';
$config['username_domain'] = '%d';

// ----------------------------------
// SMTP
// ----------------------------------
$config['smtp_server'] = 'tls://mail.%d';
$config['smtp_port'] = 587;
$config['smtp_user'] = '%u';
$config['smtp_pass'] = '%p';
$config['smtp_auth_type'] = 'PLAIN';

// ----------------------------------
// SYSTEM
// ----------------------------------
$config['enable_installer'] = false;
$config['product_name'] = 'Webmail SENE-NET';
$config['cipher_method'] = 'AES-256-CBC';

// ----------------------------------
// EXTRA CONFIGURATION
// ----------------------------------
// provide an URL where a user can get support for this Roundcube installation
// PLEASE DO NOT LINK TO THE ROUNDCUBE.NET WEBSITE HERE!
$config['support_url'] = 'https://sene.ovh';

// This key is used for encrypting purposes, like storing of imap password
// in the session. For historical reasons it's called DES_key, but it's used
// with any configured cipher_method (see below).
$config['des_key'] = 'JZUH4FTsIUJJE4l6J5CTZeKz';

// ----------------------------------
// USER PREFERENCES
// ----------------------------------
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

// Use this charset as fallback for message decoding
$config['default_charset'] = 'UTF-8';

// skin name: folder from skins/
$config['skin'] = 'larry';

// Default messages listing mode. One of 'threads' or 'list'.
$config['default_list_mode'] = 'threads';

// Prefer displaying HTML messages
$config['prefer_html'] = true;

// Compose html formatted messages by default
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
