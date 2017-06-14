# Class: winparams
# ===========================
#
# Full description of class winparams here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'winparams':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Author Name <author@domain.com>
#
# Copyright
# ---------
#
# Copyright 2017 Your name here, unless otherwise noted.
#
# TODO: use $::os[windows][system32] (or $::system32) to obtain system_root
# TODO: use $::puppet_vardir to obtain $puppetconf
# TODO: get rid of hard coded localized folder names such as "Dados de aplicativos" and "Menu Iniciar" (Portuguese)
# TODO! get temp dir from a fact using
# http://stackoverflow.com/questions/35428502/get-temp-directory-on-windows-using-puppet
# and fallback to fact[puppet_vardir] when not found
class winparams($system_root = "C:\\" ) {

  # In order to support puppet 3.8.x the following legacy facts were used instead of the new ones:
  # os[architecture] => architecture
  # os[family] => osfamily
  # os[windows][system32] => system32
  #
  # That's because 3.8.x does not support structured facts - it has access only to the first level.
  #
  # To support the more readable and maintainable syntax $facts[fact], you must enable
  # "future=parse" and "trusted_node_data=true". References:
  #
  # https://docs.puppet.com/puppet/3.8/lang_facts_and_builtin_vars.html#the-factsfactname-hash
  # https://docs.puppet.com/puppet/3.8/config_important_settings.html#recommended-and-safe
  # https://docs.puppet.com/puppet/3.8/experiments_future.html#enabling-the-future-parser

  info('FACTS:')
  info("facts[architecture]     = ${facts[architecture]}")
  info("facts[kernelmajversion] = ${facts[kernelmajversion]}")
  info("facts[osfamily]         = ${facts[osfamily]}")
  info("facts[puppet_vardir]    = ${facts[puppet_vardir]}")
  info("facts[system32]         = ${facts[system32]}")
  info("facts[username]         = ${facts[username]}")

  if $facts[osfamily] != 'windows' {
    fail('Unsupported platform. This module is Windows only.')
  }

  $platform = $facts[kernelmajversion] ? {
    /10[.]./ => 'w10',
    '6.3'    => 'w81',
    '6.2'    => 'w8',
    '6.1'    => 'w7',
    '6.0'    => 'wvista',
    '5.1'    => 'wxp',
    default  => fail('Unsupported Windows version. This module works with Windows XP/Vista/7/8/8.1/10'),
  }
  $platform_arch = "${platform}_${facts[architecture]}"

  # Set system paths according to the platform
  case $platform {
    'wxp': {
      $desktop       = "${system_root}Documents and Settings\\${facts[username]}\\Desktop"
      $desktop_all   = "${system_root}Documents and Settings\\All Users\\Desktop"
      $programdata   = "${system_root}Documents and Settings\\All Users\\Dados de aplicativos"
      $programfiles  = "${system_root}Arquivos de programas"
      $puppetconf    = "${system_root}Documents and Settings\\All Users\\Dados de aplicativos\\PuppetLabs\\puppet\\etc\\puppet.conf"
      $startmenu     = "${system_root}Documents and Settings\\${facts[username]}\\Menu Iniciar"
      $startmenu_all = "${system_root}Documents and Settings\\All Users\\Menu Iniciar"
      $userprofile   = "${system_root}Documents and Settings\\${facts[username]}\\Dados de aplicativos"
    }
    default: {
      $desktop       = "${system_root}Users\\${facts[username]}\\Desktop"
      $desktop_all   = "${system_root}Users\\Public\\Desktop"
      $programdata   = "${system_root}ProgramData"
      $programfiles  = "${system_root}Program Files"
      $puppetconf    = "${system_root}ProgramData\\PuppetLabs\\puppet\\etc\\puppet.conf"
      $startmenu     = "${system_root}Users\\${facts[username]}\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu"
      $startmenu_all = "${system_root}ProgramData\\Microsoft\\Windows\\Start Menu"
      $userprofile   = "${system_root}Users\\${facts[username]}\\AppData\\Roaming"
    }
  }

  # Program Files varies with the architecture
  case $platform_arch {
    'wxp_x86': {
      $programfiles32 = "${system_root}Arquivos de programas"
    }
    'wxp_x64': {
      $programfiles32 = "${system_root}Arquivos de programas (x86)"
    }
    'w7_x86', 'wvista_x86': {
      $programfiles32 = "${system_root}Program Files"
    }
    default: {
      $programfiles32 = "${system_root}Program Files (x86)"
    }
  }

  # Location of commonly-used programs from system32.
  $certutil = "${facts[system32]}\\certutil.exe"
  $cmd = "${facts[system32]}\\cmd.exe"
  $msiexec = "${facts[system32]}\\msiexec.exe"
  $powershell = "${facts[system32]}\\WindowsPowershell\\v1.0\\powershell.exe -executionpolicy remotesigned -file"
  $regsvr32 = "${facts[system32]}\\regsvr32.exe"

  # Temporary directory
  $tempdir = regsubst($facts[puppet_vardir], '[/]', '\\', 'G')

  info('VARIABLES:')
  info("certutil       = ${certutil}")
  info("cmd            = ${cmd}")
  info("desktop        = ${desktop}")
  info("desktop_all    = ${desktop_all}")
  info("msiexec        = ${msiexec}")
  info("platform       = ${platform}")
  info("platform_arch  = ${platform_arch}")
  info("powershell     = ${powershell}")
  info("programdata    = ${programdata}")
  info("programfiles   = ${programfiles}")
  info("programfiles32 = ${programfiles32}")
  info("puppetconf     = ${puppetconf}")
  info("regsvr32       = ${regsvr32}")
  info("startmenu      = ${startmenu}")
  info("startmenu_all  = ${startmenu_all}")
  info("tempdir        = ${tempdir}")
  info("userprofile    = ${userprofile}")

}