# pip install Pillow
import dataclasses
from PIL import Image, ImageFont, ImageDraw
import projutils.png as png
import projutils.color as color

# use a truetype font (.ttf)
# font file https://managore.itch.io/m6x11
font_path = "python/data/"
font_name = "m6x11.ttf"
out_path = "python/out/"

font_size = 16 # px
font_color = "#000000" # HEX Black

# Create Font using PIL
font = ImageFont.truetype(font_path+font_name, font_size)

# Copy Desired Characters from Google Fonts Page and Paste into variable
desired_characters = "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_abcdefghijklmnopqrstuvwxyz{|}~ ¡¢£¤¥¦§¨©ª«¬®°±²³´µ¶¹º»¿×÷"

@dataclasses.dataclass
class CharData:
    id: int
    width: int
    char: str

data = {}

HEIGHT = 16*0x10
WIDTH = 8*0x10
imgpreview = Image.new("RGBA", (WIDTH, HEIGHT))
imgexport = Image.new("RGBA", (WIDTH, HEIGHT))
imgexport2 = Image.new("RGBA", (8, 0x100*16))

def fix_MmWw(img):
    new_img = Image.new("RGBA", (8, 16))
    cropped = img.crop((0, 0, 4, 16))
    new_img.paste(cropped, (0, 0, 4, 16))
    cropped = img.crop((4, 0, 8, 16))
    new_img.paste(cropped, (3, 0, 7, 16))
    return new_img


# Loop through the characters needed and save to desired location
for id, character in enumerate(desired_characters):
    
    # Get text size of character
    left, top, right, bottom = font.getbbox(character)
    width = right - left
    
    # Save the data
    chardatum = CharData(id, width, character)
    data[chardatum.id] = (chardatum)

    # Create PNG Image with that size
    # Draw the character
    charimg = Image.new("RGBA", (8, 16))
    drawchar = ImageDraw.Draw(charimg)
    drawchar.text((0, 0), str(character), font=font, fill=font_color)
    if character in 'MmWw':
        charimg = fix_MmWw(charimg)

    imgpreview.paste(charimg, ((chardatum.id % 16)*8, chardatum.id//16*16, (chardatum.id % 16)*8+8, chardatum.id//16*16+16))

    cropped = charimg.crop((0, 0, 8, 8))
    imgexport.paste(cropped, ((chardatum.id % 8)*16, chardatum.id//8*8, (chardatum.id % 8)*16+8, chardatum.id//8*8+8))
    cropped = charimg.crop((0, 8, 8, 16))
    imgexport.paste(cropped, ((chardatum.id % 8)*16+8, chardatum.id//8*8, (chardatum.id % 8)*16+16, chardatum.id//8*8+8))

    imgexport2.paste(charimg, (0, chardatum.id*16, 8, chardatum.id*16+16))

def saveimg(img, width, height, name):
    pixels_flat = list(img.getdata())
    for i, pixel in enumerate(pixels_flat):
        if pixel == (0, 0, 0, 255):
            pixels_flat[i] = 0
        elif pixel == (0, 0, 0, 0,):
            pixels_flat[i] = 3
        else:
            raise KeyError
    pixels = [pixels_flat[i * width:(i + 1) * width] for i in range(height)]

    pal = color.Palette.init_greyscale_palette()
    filename = out_path + name
    bitdepth = 2 if len(pal) == 4 else 8
    with open(filename, 'wb') as f:
        w = png.Writer(width, height, bitdepth=bitdepth, palette=pal.get_png_palette())
        w.write(f, pixels)
saveimg(imgpreview, WIDTH, HEIGHT, 'font_preview.png')
saveimg(imgexport, WIDTH, HEIGHT, 'font_export.png')
saveimg(imgexport2, 8, 0x100*16, 'font_export2.png')

for datum in data.values():
    if datum.width > 8:
        datum.width = 8


for i in range(0x100):
    if i in data:
        datum = data[i]
        print(f'    Charmap_Register "{datum.char}", ${datum.id:02X}, ${datum.width:02X}')
    else:
        print(f'    Charmap_Register "NONE", ${i:02X}, ${0xFF:02X}')
