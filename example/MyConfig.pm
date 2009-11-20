package MyConfig;
use base 'Config::General::Hierarchical';
sub syntax {
    my ( $self ) = @_;
    my %constraint = (
        GMTOffsett => 'I',
        IdString   => 'm',
    );
    return $self->merge_values( \%constraint, $self->SUPER::syntax );
}
1;
