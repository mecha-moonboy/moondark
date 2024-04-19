def read_conf_file(filename):
    f = open(filename, 'r')
    return read_conf(f)

def read_conf(f, end_tag=None):
    conf = {}
    while True:
        line = f.readline()
        if len(line) == 0:
            return conf
        line = line.strip()
        if line == end_tag:
            return conf
        if len(line) == 0 or line[0] == '#':
            continue

        eqpos = line.find('=')
        if eqpos < 0:
            continue
            
        name, value = line[:eqpos].rstrip(), line[eqpos+1:].lstrip()
        if value == '{':
            # Group
            conf[name] = read_conf(f, end_tag='}')

        elif value == '"""':
            # Multiline
            conf[value] = read_multiline(f)

        else:
            conf[name] = value

def read_multiline(f):
    mline = ''
    while True:
        line = f.readline()
        if len(line) == 0:
            return mline
        line = line.strip()
        if line == '"""':
            return mline
        mline += line + '\n'
