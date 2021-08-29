path = "/home/admin"
images_source_dir = "#{path}/images_source"
images_tf_dir = "#{path}/images_tf"
output_dir = "#{path}/output"

def exe(program, *args)
  system("#{program} #{args.join(' ')}")
end

def python(program, *args)
  exe("python", program, *args)
end

def create_tf_records(images_source_dir, images_tf_dir, output_dir)
  python("dataset_tool.py", "create_from_images", images_tf_dir, images_source_dir)
end

def train(images_source_dir, output_dir, **args)
  python("train.py", "--gpus=1", "--output=#{output_dir}", "--data=#{images_source_dir}", **args)
end

path = "/home/admin"
images_source_dir = "#{path}/images_source"
images_tf_dir = "#{path}/images_tf"
output_dir = "#{path}/output"

#run mogrify
#
# # convert images to tfimages
# # python dataset_tool.py create_from_images ~/datasets/metfaces ~/downloads/metfaces/images
# source_dir dest_dir
#
#
# # start training
#
# python train.py --outdir=~/training-runs --gpus=1 --data=~/datasets/custom --dry-run
# source_dir output_dir training_options
#
# # generate images from trained neural net before exiting
# #python generate.py
