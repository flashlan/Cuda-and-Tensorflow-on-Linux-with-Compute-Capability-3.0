#!/bin/bash

function usage {
  echo "--- inttf NVIDIA patcher ---"
  echo "script usage: $(basename $0) [-h] [-v 340.108, 390.157, 418.113, 435.21, 470.199.02] [-d opensuse-leap]" >&2
}

function get_opts {
  local OPTIND
  while getopts "hv:d:" opt; do
    case $opt in
      v) 
        nvidia_version=$OPTARG
        ;;
      d)
        distro=$OPTARG
        ;;
      h)
        usage
        exit 0
        ;;
      *) 
        usage
        exit 1
        ;;
      \?)
        usage
        exit 1
        ;;
    esac
  done
  if [ $OPTIND -eq 1 ]; then 
    usage
    exit 1;
  fi
}

function check_version {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  usage
  exit 1;
}

function check_file {
  if [ ! -f ./$1 ]; then
    echo Downloading... $2
    wget -O $1 $2
  else
    echo $1 found.
  fi
  if [ "$(b2sum < ./$1)" = "$3  -" ]; then
    echo $1 [OK]
  else
    echo $1 [Fail]
    echo Deleting... $1
    rm ./$1
    echo Downloading... $2
    wget -O $1 $2
    if [ "$(b2sum < ./$1)" = "$3  -" ]; then
      echo $1 [OK]
    else
      echo $1 [Fail]
      exit 1
    fi
  fi
}

get_opts "$@"

nvidia_versions=( '340.108' '390.157' '418.113' '435.21' '470.199.02' )

check_version $nvidia_version "${nvidia_versions[@]}"

nvidia_short_ver=${nvidia_version%%.*}
nvidia_directory="NVIDIA-Linux-x86_64-${nvidia_version}"
nvidia_file="NVIDIA-Linux-x86_64-${nvidia_version}.run"
nvidia_url="https://us.download.nvidia.com/XFree86/Linux-x86_64/${nvidia_version}/${nvidia_file}"
nvidia_340xx_b2sum="890d00ff2d1d1a602d7ce65e62d5c3fdb5d9096b61dbfa41e3348260e0c0cc068f92b32ee28a48404376e7a311e12ad1535c68d89e76a956ecabc4e452030f15"
nvidia_390xx_b2sum="44b855cd11f3b2f231f9fb90492ae2e67a67ea3ea83c413e7c90956d38c9730a8bd0321281ae03c6afce633d102f5b499aed25622b9bfd31bdd2c98f0717e95b"
nvidia_418xx_b2sum="b335f6c59641ee426aff2b05a495555ec81455a96c629727d041674f29bd4b5e694217ea9969ccf5339038c5a923f5baf5888491554a0ca20d6fc81faaaf8a27"
nvidia_435xx_b2sum="e9afd6335182a28f5136dbef55195a2f2d8f768376ebc148190a0a82470a34d008ce04170ffc1aab36585605910c1300567a90443b5f58cb46ec3bff6ab9409c"
nvidia_470xx_b2sum="5ceca89da4b4c7de701602d3dbf26e71a1163be26e0e5eac65354ecd40bfc8d68c981a6ef75b13e95079835c95ef7f9e10e5f95a0ed09beffd5bc22cb81a5330"
nvar=nvidia_${nvidia_short_ver}xx_b2sum
nvidia_b2sum=${!nvar}

patch_url="https://nvidia.if-not-true-then-false.com/patcher/"

case "${nvidia_short_ver}" in
  340)
    case "${distro}" in
      opensuse-leap)
        patch_file_names=(
          '0001-fix-compile-on-5.6-rc1.patch'
          '0002-fix-compile-on-5.7-rc1.patch'
          '0004-fix-compile-on-5.8.patch'
          '0005-fix-compile-on-5.9.patch'
          '0006-fix-compile-on-5.10.patch'
          '0007-fix-compile-on-5.14.patch'
          'inttf-nv-acpi.patch'
          'inttf-nv-drm.patch'
          'license.patch' )
        patch_file_b2sums=(
          'ffb860a2d4477e7b050b983833e01d08dbaa944f81165bf8bfa5f0746abbdc80328bc5846227d572050a9db90de423538bc47446c616aa32b2fb919d28aa9a37'
          'c4c3414c96b7cf993ec572106067a0863982d9823eabb5c33d37225a48801ae69360afd571136bd2fc49273a2cf4b6d357e3529cf8fba35b0e185d1d7467f4c2'
          '27bc0fb992d4b8165631a3aab7f794cf0185f6e3958a6bc0447c75806c2f1f8966aa4f7c85d9c9cb438747440482037492fda0a0f7a433131d38c5f9f05f7e9e'
          '7a22c8a2570b06586a9d075c8a4cb5a1640002ea1a6d8059291d2c4101b29759832459b78fb6ebe652888f2bbdd38fc6c00875dab70bdb20955d416cde1e86b8'
          '915457f38897fa512622e09007ec203f67d2a7252c3bed41fdc2d6df2a7a5b10db97ad518235267b9eb928773963c06f1de53d5d06dc90055b3ebfeefed0fd24'
          'cca73cb7643fa3eb22d2bb01f08f2168fd6fd66687323af21fb7b69d13198ea205a4c14b154ea14bfd3ce3763a0ceec4acc142992522499919ada79c8ea9bb05'
          '0a18176412df428fdc8e7abdb0029b1bd3912964104ec7505f547336a252f3df24fd09ffde57a059cab98b0b03702764e2fb28f48aab6a2a10d7df510ddcc4a5'
          'bb978f17002894d65d6c49d51182e7d9e2fe51764f2c7914fe084884a61b386adc8e103eabfc61f0a91f82fd4f0ff88a328b96d17b54a9556197c3bdfc716f9f'
          'd8851560c0cab4b16f4dba844b1cc65fd9d00066308a31f842c5b729a1de34fc1648d27fcfc004f129631716b1053efc39e1430e617b3f4bdd33763700578b2b' )
        output_file_name=( 'patched-kernel-5.14' 'patched for kernel 5.14+' )
        ;;
      *)
        patch_file_names=( 
          'kernel-5.7.patch' 
          'kernel-5.8.patch' 
          'kernel-5.9.patch' 
          'kernel-5.10.patch' 
          'kernel-5.11.patch' 
          'kernel-5.14.patch'
          'kernel-5.15.patch'
          'kernel-5.16.patch'
          'kernel-5.17.patch'
          'kernel-5.18.patch'
          'kernel-6.0.patch'
          'kernel-6.2.patch'
          'kernel-6.3.patch'
          'kernel-6.5.patch' )
        patch_file_b2sums=( 
          '7150233df867a55f57aa5e798b9c7618329d98459fecc35c4acfad2e9772236cb229703c4fa072381c509279d0588173d65f46297231f4d3bfc65a1ef52e65b1' 
          'b436095b89d6e294995651a3680ff18b5af5e91582c3f1ec9b7b63be9282497f54f9bf9be3997a5af30eec9b8548f25ec5235d969ac00a667a9cddece63d8896' 
          '947cb1f149b2db9c3c4f973f285d389790f73fc8c8a6865fc5b78d6a782f49513aa565de5c82a81c07515f1164e0e222d26c8212a14cf016e387bcc523e3fcb1' 
          '665bf0e1fa22119592e7c75ff40f265e919955f228a3e3e3ebd76e9dffa5226bece5eb032922eb2c009572b31b28e80cd89656f5d0a4ad592277edd98967e68f'
          '344cd3a9888a9a61941906c198d3a480ce230119c96c72c72a74b711d23face2a7b1e53b9b4639465809b84762cdc53f38210e740318866705241bc4216e4f35'
          '31a4047ab84d13e32fd7fdbf9f69c696d3fab6666c541d2acf0a189c1d17c876970985167fd389a4adc0f786021172bdec1aa6d690736e3cf9fcd8ceabe5fd32' 
          'b3b7bbd597252b25ccb68f431f83707a10d464996f6c74bb67143795df96054da719faf09c1ad2e1c215261356833ad3fa0d9e60552151f827f9d7be7ae44605'
          'caedc5651bfd14c02fb677f9c5e87adef298d871c6281b78ce184108310e4243ded82210873014be7fedee0dd6251305fa9bbce0c872b76438e0895ef76109d9'
          '0266e1baaac9ffbb94d9e916a693b1663d8686b15e970bfc30f7c51f051a0af9267aa5f6a12b68586c69d2e9796a1124488b3997ba4b26db1a5ac10a892f0df2'
          'd69c9acbe550d5fccca68ca6a0d5095cbcaf887d2bc43704a8eb85533896692f16701eef07ead297881f596f5502c3105bb5bea77b2dcaf6c4dc2b49941f9f19'
          '682a7b8e58d2a008531b7e5179e32c0c71adad673891a1057acd1aa26e410d9d93ff607e46257c6701619621cee1a27e613ec9ae19a580acdd6f68f1c1fdedea'
          '47681d1e4b16f0b50775120b0a02bc6d279de692cde6086b895eef80bb4598e914ffe1fae81707a771d00f23df60ee4df591dfe042f5b764856d2e07306f3821'
          'ae16e2a5674a8a93c85aa624e73b1671e85b2be1854caf967986f5764b946f7ca39a1e75c1617ee79da40a8d9a86cc1b17f64a787bc7a8c38f8dca426edeff46' 
          '01192b20986be28bd270842afcf022fbe43536dc2aac6479bc41b7760118aee8e6610290444212ed117d1a006bc24cca205aa39ccc760c6cbcb42f9102b815eb' )
        output_file_name=( 'patched-kernel-6.5' 'patched for kernel 6.5+' )
        ;;
    esac
    ;;
  390)
    patch_file_names=(
      'kernel-4.16+-memory-encryption.patch'
      'kernel-6.2.patch'
      'kernel-6.3.patch'
      'kernel-6.4.patch' 
      'kernel-6.5.patch' )
    patch_file_b2sums=(
      'a8234f542c2324ad698443e3decf7b6eacf3cb420b7aded787f102a8d32b64c2a8d45ea58e37a5e3b6f2f060f0cccd63d3a182065f57c606006d0ff8c7f6bb05'
      'dd1153903badbb9c2401c583a983ce5a413da2afffa6dd3ef6e839933a1c994518d5bfbcaf6800496e0d40785a4e7eb0770c8a739fe231ad3085c541bcb3f2b2'
      '09f674b2bd55d40df072b70598b78d6a4e57f80a974f99d39b9cd95e0e20cd5698b9b48671b5cb85fcda780d4badc84c8caa5104d2a5c5f85b37841109101701' 
      'f9ee14546802eb180a650d91cbf7bcaa046afe80a4ac07624a6d2c186db956d9b055c21dd05987b5ad39be205255142c11f73d39fe6f9c7a3d9553f8ac8ad221' 
      '0d4101e8d55b853613ddf53a4f258beda23c89bb2beb2cede6be7ecb1a35be1a81604363e2367d06e6bcd64ba4424eb7d2766c6468ebb9bb75d06ac2b40edbeb' )
    output_file_name=( 'patched-kernel-6.5' 'patched for kernel 6.5+' )
    ;;
  418)
    patch_file_names=( 
      'kernel-5.5.patch' 
      'kernel-5.6.patch' 
      'kernel-5.7.patch' 
      'kernel-5.8.patch' 
      'kernel-5.9.patch' 
      'kernel-5.10.patch'
      'kernel-5.11.patch' 
      'license.patch' )
    patch_file_b2sums=( 
      'fae57c950f4906fa95801c2676cb9c4fd831c9e1c5333223fb68f3fb7dbb994742873ae307723eb0d7547a4a4c655d3bacb7e4d7e8e0f11051300fdb1098489a' 
      'b45a707f09feb32fd17df9e2582ef1ae77a4a21e6fcc51abc81d59c7e5e831c1c5fbcd3f06829fc084bed4a4ee3fdcbfc88ac2ba8a28d3c48d66ea539e490feb' 
      'e290a02036cb4a41b8c561aa9ad67971392550de9c4fd4f8106848752068fd544f48ae07736e40313bc71a9f8beee9f9a9b317e8931a686ccb9cf4af9ecc4430' 
      '4241170d7ab8eda68b51893090c7ba2dffab1bc6316affa84aa2786a5f428874b9008febda8f20a761e08c1c79d962547e577fc59f2db97b42434fc76588aad6' 
      '4bcd4094bab3349fbf4d784f5aaa6137930089d6e228f2adb86e960f2fd4ebe84c750f1c39e47f0d5372434b6f429a3a5921a7a590a4b4000a4b8d88d7583b06' 
      'db272697c06972ea3b4f3edd9802bc0fc9e9fca931a4559caf1944042fe88336a08ed7d9d06e49270853b9fd53a029a7fd3c3dcebb5c2087857078d7966c1b75' 
      'f1fa9292dffa046c3d46ce5e56d8db4f5897dc0f383825f8b7de35b46dceca5f7b41936ab23a65cf355bcd6e37f1dab8f565498f649b914b1a454d75dc8d1532'
      '0472598d8ce4c60a93ef9843ab01b1ab99a647882e55ee2d666b6e10b2a43fabcee6a0d26f4674e224430c4af0ef9af5a4f277ad4e0ef2d13f5c30afe85100b3' )
    output_file_name=( 'patched-kernel-5.16' 'patched for kernel 5.16+' )
    ;;
  435)
    patch_file_names=( 
      'kernel-5.4.patch' 
      'kernel-5.5.patch' 
      'kernel-5.6.patch' 
      'kernel-5.7.patch' 
      'kernel-5.8.patch' 
      'kernel-5.9.patch' 
      'kernel-5.10.patch' 
      'kernel-5.11.patch'
      'license.patch' )
    patch_file_b2sums=( 
      '586982cdbbb7751dc75f9b1c33ca033703170d0329c9c19e02bc32df732b6d7f102c5f703f8e4ec3a7152cb5a6ce87e0ed0fd3df95b040655b409ad59e0c210d' 
      '26bdf3240caf5a8382703e9193e43993c518dcba325679f2e314d9ab69f7f11400d1fe0e4f99618bd1eaacb737143f37eedce363acfb78a5631c2bfc9a2e9150' 
      'e7b6ea3fae0bd92bdc0a934466313a48075b8e11b27cbdec328ec3bcb415d2c89aaf61cb0dc5506aaceb537162e8f833e55607a4db12ab3a6475f3b8ac736bff' 
      'e4ad99e110bbd8539b9ebf5ec5269db5db1ae2bc23b0fd6c1a2cb396b782a48a849c98de4a535327dc8cb2e73e50aad79e3fc2cb4d2b806cecc7c23aa06aa466' 
      'e77dfd9aa5629a66e8cfacb3afde1ef74b26f6471287b43b6e0fc58bb4686cab919a49ba2e9a6f931b4f443e49bf82ee759067a7c7477a965aa9295b223d8217' 
      '7c5e6c9b37965c1e35fa35b99c8497afa50fd5e72f3494b02654e85b96e9982193e7a27d3b681c6b9de59f54bb5708950d3dc2640aa2a22ab4cc40e3163d42c9' 
      'da7cbd06fe7dbcd704be4f97fbdd39ea10d149fbded4773420e94318571800d62c619c801a270abcda92ae48662adb01c8d48a5e0cc85fa4532a2ce056d4e698'
      '1448dca042897bde8e14c7572c61344cd5df1b1a46f0fe832fa726cf8cff513537cdfac251d1042a7566d2c362e42af9d8c7118cad2e689d19ce381e8827d745'
      'badf91ac5b0d0ef5d5eda85b79447b475216b4692b19380f495670c961baa0b6f0d6687d2393c29edc22115f40e94705e488471265d30124b0a0775105638756' )
    output_file_name=( 'patched-kernel-5.16' 'patched for kernel 5.16+' )
    ;;
  470)
    patch_file_names=(
      'kernel-6.4.patch'
      'kernel-6.5.patch'
      'kernel-6.6.patch' )
    patch_file_b2sums=(
      '82c827c2aecf237eb4b86133e36ca546864553841581386883b6840003aae4b075f1a340211fbcfba3d5902b6b2f0ccd412214a102acb6ef0fc39162ab98f076'
      '5de2efb24b207473cbf68af37ce7302678d10233fe04b3bc63d9f6c7a55f89489f3d97cc6a2140f063d9ca1273dbbd4c8505d173cd98b17ae0a1372a6bce29a6'
      '98f7c0f76a1b51cec212068f4d9ab23e8c41055df2d02d052a405eecd67388d3e408659605e8016afd194515c6e15057ae98bf2e5539212def6d1b2002e7cf02' )
    output_file_name=( 'patched-kernel-6.6' 'patched for Kernel 6.6+' )
    ;;
esac

check_file $nvidia_file $nvidia_url $nvidia_b2sum

path=""
if [ -n "$distro" ]
then
  path="NVIDIA-${nvidia_short_ver}xx-${distro}"
else
  path="NVIDIA-${nvidia_short_ver}xx"
fi
mkdir -p ${path}

for i in "${!patch_file_names[@]}"; do
  echo ${patch_file_names[$i]} $patch_url ${patch_file_b2sums[$i]}
  check_file "${path}/${patch_file_names[$i]}" "$patch_url${path}/${patch_file_names[$i]}" ${patch_file_b2sums[$i]}
done

chmod +x ./$nvidia_file

if [ -d ./$nvidia_directory ]; then
  rm -rf ./$nvidia_directory
fi

./$nvidia_file --extract-only

cd ./$nvidia_directory

for f in "${patch_file_names[@]}"; do
  patch -Np1 -i ../${path}/$f
done

cd ..

./$nvidia_directory/makeself.sh --target-os Linux --target-arch x86_64 $nvidia_directory $nvidia_directory-${output_file_name[0]}.run "NVIDIA driver $nvidia_version ${output_file_name[1]}" ./nvidia-installer

exit 0





