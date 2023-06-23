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



for i in range(8):
    for j in range(32):
        id = j - i*10
        if not (0 <= id <= 9):
            id = 0x10
        tm.map.append(id)

tm.save_original_file('python/out/sky_test.tilemap')


for i in range(8):
    for j in range(32):
        count = j - i*10
        id = 7
        if not (0 <= count <= 9):
            id = 6
        am.map.append(id)

am.save_original_file('python/out/sky_test.attrmap')