from PIL import Image, ImageDraw

width = 1024
height = 1024
im = Image.new('RGB', (width, height))
draw = ImageDraw.Draw(im)

c1 = (124, 58, 237)
c2 = (76, 29, 149)

pixels = im.load()
for y in range(height):
    for x in range(width):
        t = (x * width + y * height) / (width * width + height * height)
        r = int(c1[0] + (c2[0] - c1[0]) * t)
        g = int(c1[1] + (c2[1] - c1[1]) * t)
        b = int(c1[2] + (c2[2] - c1[2]) * t)
        pixels[x, y] = (r, g, b)

try:
    emoji = Image.open('money.png').convert('RGBA')
    emoji = emoji.resize((600, 600), Image.Resampling.LANCZOS)
    offset = ((width - 600) // 2, (height - 600) // 2)
    im.paste(emoji, offset, emoji)
except Exception as e:
    print("Error pasting emoji:", e)

im.save('assets/logo.png')
print("Generated assets/logo.png")
