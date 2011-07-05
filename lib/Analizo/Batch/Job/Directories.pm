package Analizo::Batch::Job::Directories;

use base qw( Analizo::Batch::Job Class::Accessor::Fast );
use Cwd;

sub new {
  my ($class, $directory) = @_;
  return bless { directory => $directory }, $class;
}

__PACKAGE__->mk_accessors(qw(directory oldcwd));

sub prepare {
  my ($self) = @_;
  $self->oldcwd(getcwd);
  chdir($self->directory);
}

sub cleanup {
  my ($self) = @_;
  chdir($self->oldcwd);
}

1;
