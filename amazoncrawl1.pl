#!/usr/bin/perl
#use strict;
#use warnings;

use LWP::Simple;
use Data::Dumper;

my @urls = ("http://www.amazon.in/s/ref=sr_abn_pp_ss_1389432031?ie=UTF8&bbn=1389432031&rh=n%3A1389432031");
#my @urls = ("http://www.amazon.in/s/ref=sr_abn_pp_ss_1389432031?ie=UTF8&bbn=1389432031&rh=n%3A1389432031")

foreach my $url (@urls) {
    print STDERR "Crawling $url\n";
    my $content = get($url);
    my $fields = extractFields($content);

    my $additionalUrls = extractUrls($content);
    push(@urls, @{$additionalUrls}) if defined $additionalUrls;
    
    #-- Randomly sleep between 1s and 5s
    sleep (int(rand(4)) + 1);
}

sub extractUrls {
    my ($content) = @_;
    my @urls;

    return if $content =~ /<\/h4>/;

    #-- Content URLs
    while ($content =~ /href="([^\"]+)">[^<]+<\/a><\/div><\/div><\/li><li id="[^\"]+" data\-asin/g) {
        my $url = $1;
        #$url = "http://www.amazon.in".$url;
        $url =~ s/#.*//;
        print STDERR "Found content url: $url\n";
        push(@urls, $url);
    }
    
    #-- Pagination URLs
    if ($content =~ /<span class="pagnLink"><a href="([^\"]+)"/) {
        my $pageurl = $1;
        $pageurl = "http://www.amazon.in".$pageurl;
        #$url =~ s/.*//;
        print STDERR "Found pagination url: $pageurl\n";
        push(@urls, $pageurl);
    }
    
    return \@urls;;
}
    
sub extractFields {
    my ($content) = @_;
    
    #return if $content !~ /i/;
    my $data;
    my @features_array;

    #-- Extract name
    if ($content =~ /<span id="productTitle"[^>]*>\s*([^<]+<\/span>)/) {
        my $name = $1;
        $name =~ s/\s*<\/span>//sig;
        $data->{name} = $name;
    }  
    

    while ($content =~ /<td class=\"label\"[^>]*>\s*([^<+]\s*[^<]+<\/td>\s*<td\s*class\=\s*\"value\">[^<]+)/g) {
            my $line = $1;
            $line =~ s/<\/td>//sig;
            $line =~ s/<td class="value">/\:/sig;
            $line =~ s/Best Sellers Rank:.*//sig;
            if ($line){
            push (@features_array, $line);
        }
        }
        while ($content =~ /<li><span class=\"a-list-item\">\s*([^<]+)<\/span>\s*<\/li>/g) {
            my $line2 = $1;
            $line2 =~ s/<\/td>//sig;
            $line2 =~ s/<td class="value">/\:/sig;
            $line2 =~ s/Best Sellers Rank:.*//sig;
            if ($line2){
            push (@features_array, $line2);
        }
        }

        $data->{feature} = \@features_array;
    #}  

    #-- Extract price
    if ($content =~ /<span id="priceblock\_ourprice"[^>]+><span[^>]+>[^<]+<\/span>([^<]+)<\/span>/) {
        $data->{price} = $1;
    }    
    print STDERR Dumper $data;
}

