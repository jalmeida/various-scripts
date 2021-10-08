#!/usr/bin/perl
# Usage: ./per-nitya.pl bigip.conf <search-string>

  my ($File, $Pattern) = @ARGV;
  my ($CurlyBraces, $Object) = (0, "");

  open (fh, $File) || die "Cant open $File";
  while ( <fh> ){
          $Object .= $_;
          $CurlyBraces += (tr/\{//);
          $CurlyBraces -= (tr/\}//);

          if ($CurlyBraces == 0) {
                  print $Object if ($Object =~ /$Pattern/s);
                  $Object = "";
          }
  }
  close (fh);
