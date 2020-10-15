set -e
mkdir -p build
pushd build
cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo
make -j$(nproc)
./clear_tests
sudo make install
popd
