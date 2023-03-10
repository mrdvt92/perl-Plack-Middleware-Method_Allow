Name:           perl-Plack-Middleware-Method_Allow
Version:        0.01
Release:        1%{?dist}
Summary:        Perl Plack Middleware to filter HTTP Methods
License:        MIT
Group:          Development/Libraries
URL:            http://search.cpan.org/dist/Plack-Middleware-Method_Allow/
Source0:        http://www.cpan.org/modules/by-module/Plack/Plack-Middleware-Method_Allow-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch
BuildRequires:  perl(ExtUtils::MakeMaker)
BuildRequires:  perl(Plack::Middleware)
BuildRequires:  perl(Plack::Util::Accessor)
Requires:       perl(Plack::Middleware)
Requires:       perl(Plack::Util::Accessor)
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))

%description
Explicitly allow HTTP methods and return 405 METHOD NOT ALLOWED for
all others

%prep
%setup -q -n Plack-Middleware-Method_Allow-%{version}

%build
%{__perl} Makefile.PL INSTALLDIRS=vendor
make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT

make pure_install PERL_INSTALL_ROOT=$RPM_BUILD_ROOT

find $RPM_BUILD_ROOT -type f -name .packlist -exec rm -f {} \;
find $RPM_BUILD_ROOT -depth -type d -exec rmdir {} 2>/dev/null \;

%{_fixperms} $RPM_BUILD_ROOT/*

%check
make test

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%doc Changes META.json README.md
%{perl_vendorlib}/*
%{_mandir}/man3/*

%changelog
* Sun Dec 25 2022 Michael R. Davis <mrdvt92@yahoo.com> 0.01-1
- Specfile autogenerated by cpanspec 1.78.
