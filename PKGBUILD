pkgname="encrypted-storage"
pkgver="${PKGVER:-"0.0.1"}"
pkgrel="${PKGREL:-"1"}"
arch=('any')

prepare()
{
  :
}

depends=(
  "jc"
  "jq"
)

source=(
  "${pkgname}-${pkgver}.tar.gz"
)

build() {
  cd "${srcdir}"
  make PREFIX="/usr" build
} 

package() {
  cd "${srcdir}"
  make DESTDIR="${pkgdir}" install 
}