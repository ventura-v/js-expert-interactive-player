# variável para informar onde estão os arquivos
ASSETSFOLDER=assets/timeline

# exibe todos os arquivos mp4
for mediaFile in `ls $ASSETSFOLDER | grep .mp4`; do
    FILENAME=$(echo $mediaFile | sed -n 's/.mp4//p' | sed -n 's/-1920x1080//p')
    
    # pegando os arquivos de entrada
    INPUT=$ASSETSFOLDER/$mediaFile

    # pegando o caminho para criação dos diretórios
    FOLDER_TARGET=$ASSETSFOLDER/$FILENAME

    # criando os diretórios para cada arquivo
    mkdir -p $FOLDER_TARGET # -p -> cria diretórios aninhados (/foo/bar criaria os diretórios "foo" e "bar", sem a flag -p geraria erro, pois para gerar o diretório "bar" precisaria existir o diretório "foo" primeiro). Se já existir, não faz nada

    # pegando a duração de cada arquivo
    DURATION=$(ffprobe -i $INPUT -show_format -v quiet | sed -n 's/duration=//p')

    # caminho base para os arquivos de saída
    OUTPUT=$ASSETSFOLDER/$FILENAME/$FILENAME

    # caminho base para cada resolução dos arquivos de saída (neste caso, 144, 360 e 720)
    OUTPUT144=$OUTPUT-$DURATION-144
    OUTPUT360=$OUTPUT-$DURATION-360
    OUTPUT720=$OUTPUT-$DURATION-720

    # criando os arquivos de saída para cada resolução

    echo 'rendering in 720p'
    ffmpeg -y -i $INPUT \
    -c:a aac -ac 2 \
    -vcodec h264 -acodec aac \
    -ab 128k \
    -movflags frag_keyframe+empty_moov+default_base_moof \
    -b:v 1500k \
    -maxrate 1500k \
    -bufsize 1000k \
    -vf "scale=-1:720" \
    -v quiet \
    $OUTPUT720.mp4

    echo 'rendering in 360p'
    ffmpeg -y -i $INPUT \
    -c:a aac -ac 2 \
    -vcodec h264 -acodec aac \
    -ab 128k \
    -movflags frag_keyframe+empty_moov+default_base_moof \
    -b:v 400k \
    -maxrate 400k \
    -bufsize 400k \
    -vf "scale=-1:360" \
    -v quiet \
    $OUTPUT360.mp4

    echo 'rendering in 144p'
    ffmpeg -y -i $INPUT \
    -c:a aac -ac 2 \
    -vcodec h264 -acodec aac \
    -ab 128k \
    -movflags frag_keyframe+empty_moov+default_base_moof \
    -b:v 300k \
    -maxrate 300k \
    -bufsize 300k \
    -vf "scale=256:144" \
    -v quiet \
    $OUTPUT144.mp4

    # exibe os arquivos de saída
    echo $OUTPUT144.mp4
    echo $OUTPUT360.mp4
    echo $OUTPUT720.mp4
done