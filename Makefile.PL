use 5.024000;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'File::Path::Redirect',
    VERSION_FROM      => 'lib/File/Path/Redirect.pm', # finds $VERSION, requires EU::MM from perl >= 5.5
    PREREQ_PM         => {
      "constant::more"  => 0,
      "IO::FD"          => v0.3.11,
      "Export::These"   => v0.3.0,

    }, # e.g., Module::Name => 1.1
    ABSTRACT_FROM     => 'lib/File/Path/Redirect.pm', # retrieve abstract from module
    AUTHOR            => 'Ruben Westerberg <drclaw@local>',
    LICENSE           => 'mit',
    #Value must be from legacy list of licenses here
    #https://metacpan.org/pod/Module::Build::API
);
