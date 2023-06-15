import projutils.tilemap as tilemap

tm = tilemap.Tilemap()
am = tilemap.Tilemap()

class ByteVal:
    def __init__(self, val):
        self.val = val
    
    def __add__(self, other):
        if isinstance(other, ByteVal):
            self.val += other.val
        elif isinstance(other, int):
            self.val += other
        else:
            raise NotImplementedError
        
        self.val = self.val % 256
    
    def __sub__(self, other):
        return self.__add__(-int(other))



for i in range(4):
    for j in range(20):
        if j < 4:
            id = i*4 + j
        else:
            row_offset = i % 2
            row = i//2
            id = row*32 + (j-4)*2 + row_offset + 16
        tm.map.append(id)

tm.save_original_file('python/out/text_test.tilemap')


for i in range(4):
    for j in range(20):
        id = 15
        am.map.append(id)

am.save_original_file('python/out/text_test.attrmap')