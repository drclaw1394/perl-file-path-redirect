=head1 NAME

File::Path::Redirect - Path redirection

=cut

package File::Path::Redirect;

use v5.36;
our $VERSION=v0.1.0;

use IO::FD;
use Fcntl qw(O_RDONLY);
use POSIX;
use File::Spec::Functions qw<abs2rel rel2abs>;
use File::Basename qw<dirname basename>;

# IO::FD is used for pread.
# This allows reading of file without effecting the global read position of the file descriptor
#
my $default_limit=10;
my $mode=O_RDONLY;  # Read only while following links
my $magic="!<symlink>";
my $max_size=length($magic)+POSIX::pathconf("/", &POSIX::_PC_PATH_MAX);

use constant::more qw<OK=0 TOO_MANY ACCESS_ERROR NOT_A_REDIRECT>;
use Export::These qw<make_redirect follow_redirect is_redirect>;





sub make_redirect {
  my ($existing, $name)=@_;
   
  # make relative $name to existing
  my $relative=abs2rel($existing, dirname $name);
  if($relative){
    open my $fh, ">", $name or die $!;
    print $fh "$magic$relative" or die $!;
    close $fh;
    return $relative;
  }
 return undef; 
}

# Takes a path  and resolves any redirects it might initate
# Returns the recursively redirected path
#
# $path is require and is the inital path
# $limit is the optional number of redirects allowed (10 by default)
# $trace is an optional array ref, which will contain the redirects encounterd
#
# Opends a file in read mode, reads it, then closes it.
# 
# 
sub follow_redirect{
  my ($path, $limit, $trace)=@_;

  say STDERR "FOLLOW REDIREC: ", $path;
  if(!defined $limit){
    $limit=$default_limit;
  }

  if($limit == 0){
      # gone far enough. Error
      $!=TOO_MANY;      # mark as to many reidrects
      return undef;
  }

  

  # Open the file
  #
  my $fd=IO::FD::open($path, $mode);
  defined $fd or die $!;
  my $buffer="";
  my $count=0;
  # Read the contents up to the max length of path for the current system + magic header size
  my $res;
  while($res=IO::FD::pread $fd, my $data="", $max_size, $count){
    $count+=$res;
    $buffer.=$data;
  }
  defined $res or die $!;
  IO::FD::close $fd;


  # Check for magic header
  if((my $index=index($buffer, $magic))==0){
    # Found  attempt to read
    my $new_path=substr $buffer, length $magic;
    $new_path= dirname($path)."/".$new_path;
    push @$trace, $path if $trace;
    return follow_redirect($new_path, $limit-1, $trace);
  }
  else {
    # Not a redirect file, this is the target
    $!=NOT_A_REDIRECT;
    say STDERR "NOT A REDIRECT ",$path;
    return $path;
  }
}

sub is_redirect {
  my ($path)=@_;

  my $fd=IO::FD::open($path, $mode);
  defined $fd or die $!;
  my $buffer="";
  my $count=0;
  # Read the contents up to the max length of path for the current system + magic header size
  my $res;
  while($res=IO::FD::pread $fd, my $data="", $max_size, $count){
    $count+=$res;
    $buffer.=$data;
  }
  defined $res or die $!;
  IO::FD::close $fd;


  # Check for magic header
  (my $index=index($buffer, $magic))==0;
}

1;
