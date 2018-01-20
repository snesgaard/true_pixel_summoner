def __fp(name):
    return './frame/%s.png' % (name)

def __bp(name):
    return './boundry/%s.png' % (name)

def wisp(Info):
    return Info(__fp('wisp'), 64, 64, 0.15, boundry = __bp('wisp'))

def chant(Info):
    return Info(__fp('cast'), 80, 64, 0.15, start = 1, end = 3, boundry = __bp('cast'))

def cast(Info):
    return Info(__fp('cast'), 80, 64, 0.15, start = 3, boundry = __bp('cast'))

def idle(Info):
    return Info(__fp('idle'), 64, 64, 0.25, boundry = __bp('idle'))

def attack(Info):
    return Info(__fp('attack'), 128, 64, 0.1, start = 1, boundry = __bp('attack'))

def alchemist(Info):
    return Info(__fp('alchemist'), 128, 128, 0.1, boundry = __bp('alchemist'))

def alchemist_attack(Info):
    return Info(__fp('alchemist_attack'), 128, 128, 0.075, start = 1, boundry = __bp('alchemist_attack'))

def gibbles(Info):
    return Info(__fp('gibbles'), 64, 64, 0.15, boundry = __bp('gibbles'))

def al_cast(Info):
    return Info(__fp('alchemist_cast'), 128, 128, 0.1, start = 6, boundry = __bp('alchemist_cast'))

def al_dash(Info):
    return Info(__fp('al_dash'), 128, 128, 0.1, boundry = __bp('al_dash'))

def al_bdash(Info):
    return Info(__fp('al_bdash'), 128, 128, 0.1, boundry = __bp('al_bdash'))

def fencer_idle(Info):
    return Info(__fp('fencer_idle'), 128, 128, 0.1, boundry = __bp('fencer_idle'))

def fencer_cast(Info):
    return Info(__fp('fencer_cast'), 128, 128, 0.1, start = 1, boundry = __bp('fencer_cast'))
