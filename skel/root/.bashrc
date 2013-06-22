# disable history expansion
set +H

# The remaining code won't work with bash 1.x
case $BASH_VERSION in 1.*) return;; esac

# extglob was introduced in 2.02
case ${BASH_VERSINFO[0]} in
    2)
        case ${BASH_VERSINFO[1]} in
            0|01) return ;;
        esac
    ;;
esac
shopt -s extglob

# globstar was introduced in 4.0
if (( BASH_VERSINFO[0] >= 4 )); then
    shopt -s globstar
fi
