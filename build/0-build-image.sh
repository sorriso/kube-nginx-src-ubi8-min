start=`date +%s`

if [ -f env ]; then
    # Load Environment Variables
    export $(cat env | grep -v '#' | sed 's/\r$//' | awk '/=/ {print $1}' )
fi

rm ./build.log

nerdctl -n k8s.io pull registry.access.redhat.com/ubi8/ubi-minimal:$UBI8_MIN_VERSION

nerdctl build \
   --no-cache \
   --build-arg UBI8_MIN_VERSION=${UBI8_MIN_VERSION} \
   --build-arg NGINX_VERSION=${NGINX_VERSION} \
   --build-arg PCRE_VERSION=${PCRE_VERSION} \
   --build-arg ZLIB_VERSION=${ZLIB_VERSION} \
   --build-arg OPENSSL_VERSION=${OPENSSL_VERSION} \
   --build-arg NSS_WRAPPER_VERSION=${NSS_WRAPPER_VERSION} \
   --build-arg LUAJIT_VERSION=${LUAJIT_VERSION} \
   --build-arg NGX_DEVEL_KIT_VERSION=${NGX_DEVEL_KIT_VERSION} \
   --build-arg LUA_NGINX_MODULE_VERSION=${LUA_NGINX_MODULE_VERSION} \
   --build-arg LUAROCKS_VERSION=${LUAROCKS_VERSION} \
   --namespace k8s.io \
   -t l_nginx:latest .

end=`date +%s`

runtime=$((end-start))
runtimeh=$((runtime/60))
runtimes=$((runtime-runtimeh*60))

echo "Total runtime was : $runtimeh minutes $runtimes seconds"
echo "" >> ./build.log
echo "Total runtime was : $runtimeh minutes $runtimes seconds" >> ./build.log
echo ""

# kubectl run my-shell --rm -i --tty --image l_nginx:latest -- bash
