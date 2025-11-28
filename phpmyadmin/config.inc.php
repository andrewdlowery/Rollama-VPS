<?php
/* Custom config for phpMyAdmin behind a reverse proxy */

$cfg['PmaAbsoluteUri'] = 'https://db.rollama.com/';
//$cfg['ForceSSL'] = true;

/* Optional: Increase login cookie validity */
$cfg['LoginCookieValidity'] = 3600;

/* Use secret blowfish key for cookies */
$cfg['blowfish_secret'] = 'some_random_secret_key_here';