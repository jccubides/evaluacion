#!/usr/bin/perl
# Pagina web minima para probar el ejercicio de Perl con OWASP ZAP.
# Solo usa modulos que ya vienen con Perl.
use strict;
use warnings;
use IO::Socket::INET;

my %QUERY;

# ===== Piezas de apoyo (para que el codigo del ejercicio funcione) =====
sub param {                                   # lee el valor de la URL (?user=...)
    my ($nombre) = @_;
    return $QUERY{$nombre};
}
sub ExitError {                               # muestra el error y termina la peticion
    print "<p>$_[0]</p>\n";
    die "fin\n";
}
sub decodificar {                             # convierte %2F en / , + en espacio, etc.
    my ($t) = @_;
    $t =~ tr/+/ /;
    $t =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/ge;
    return $t;
}

my $servidor = IO::Socket::INET->new(
    LocalAddr => '127.0.0.1', LocalPort => 8080, Proto => 'tcp',
    Listen => 10, ReuseAddr => 1,
) or die "No pude abrir el puerto 8080: $!";
print STDOUT "Servidor listo en http://localhost:8080/\n";

while (my $cliente = $servidor->accept()) {
    my $peticion = <$cliente> // '';
    while (my $linea = <$cliente>) { last if $linea =~ /^\r?\n$/; }   # ignorar cabeceras
    my ($ruta) = $peticion =~ m{^GET\s+(\S+)};
    $ruta //= '/';
    my ($camino, $consulta) = split /\?/, $ruta, 2;
    %QUERY = ();
    for my $par (split /&/, $consulta // '') {
        my ($k, $v) = split /=/, $par, 2;
        $QUERY{decodificar($k // '')} = decodificar($v // '');
    }

    my $html = '';
    open(my $salida, '>', \$html);
    my $anterior = select($salida);

    if ($camino eq '/perfil') {
        eval {
            # ===== CODIGO DEL EJERCICIO (sin cambios) =====
            my $dataPath = "/users/cwe/profiles";
            my $username = param("user");
            my $profilePath = $dataPath . "/" . $username;

            open(my $fh, "<", $profilePath) || ExitError("profile read error: $profilePath");
            print "<ul>\n";
            while (<$fh>) {
            print "<li>$_</li>\n";
            }
            print "</ul>\n";
            # ===============================================
        };
    } else {
        print "<h1>Perfiles</h1>\n<a href=\"/perfil?user=juank\">Ver perfil de juank</a>\n";
    }

    select($anterior);
    close($salida);
    my $cuerpo = "<html><body>\n$html</body></html>\n";
    print $cliente "HTTP/1.0 200 OK\r\nContent-Type: text/html\r\n"
                 . "Content-Length: " . length($cuerpo) . "\r\nConnection: close\r\n\r\n$cuerpo";
    close($cliente);
}
