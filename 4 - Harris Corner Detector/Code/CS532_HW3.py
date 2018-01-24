# -*- coding: utf-8 -*-
"""
Created on Tue Oct 24 02:29:32 2017

@author: Kunal
"""

from PIL import Image
import numpy as np
import math as mt

'''To resize the image to replicate border pixels before convolution as per the filter_size'''
def resize_image(ip_im, filter_size):
    r, c = ip_im.shape
    filter_n = int((filter_size-1)/2)
    op_r = r+2*(filter_n)
    op_c = c+2*(filter_n)
    op_im = np.zeros((op_r,op_c))
    for i in range(r):
        for j in range(c):
            op_im[i+filter_n][j+filter_n] = ip_im[i][j]
    for i in range(filter_n):
        for j in range(filter_n):
            op_im[i][j] = op_im[filter_n][filter_n]
    for i in range(filter_n):
        for j in range(op_c-filter_n, op_c):
            op_im[i][j] = op_im[filter_n][op_c-filter_n-1]
    for i in range(op_r-filter_n, op_r):
        for j in range(filter_n):
            op_im[i][j] = op_im[op_r-filter_n-1][filter_n]
    for i in range(op_r-filter_n, op_r):
        for j in range(op_c-filter_n, op_c):
            op_im[i][j] = op_im[op_r-filter_n-1][op_c-filter_n-1]
    for i in range(filter_n):
        for j in range(filter_n, op_c-filter_n):
            op_im[i][j] = op_im[filter_n][j]
    for i in range(op_r-filter_n, op_r):
        for j in range(filter_n, op_c-filter_n):
            op_im[i][j] = op_im[op_r-filter_n-1][j]
    for i in range(filter_n, op_r-filter_n):
        for j in range(filter_n):
            op_im[i][j] = op_im[i][filter_n]
    for i in range(filter_n, op_r-filter_n):
        for j in range(op_c-filter_n, op_c):
            op_im[i][j] = op_im[i][op_c-filter_n-1]
    return op_im

'''To perform convolution of ip with filter'''
def convolution(ip,filter):
    filter_size = int(mt.sqrt(filter.size))
    filter_n = int((filter_size-1)/2)
    ip_r, ip_c = ip.shape
    r = ip_r - 2*filter_n
    c = ip_c - 2*filter_n
    op_im = np.zeros((r, c))
    for i in range(r):
        for j in range(c):
            for k in range(filter_size):
                for l in range(filter_size):
                    op_im[i][j] = op_im[i][j] + (filter[k][l] * ip[i+k][j+l])
            if(op_im[i][j] < 0):
                op_im[i][j] = 0
            else:
                op_im[i][j] = int(op_im[i][j])
    return op_im

'''To create the gaussian filter'''
def gauss_filter(og_im, size, sigma):
    size = int(size)
    sigma = float(sigma)
    #og_im = np.array(im)
    filter = np.zeros((size,size))
    filter_n = int((size-1)/2)
    y, x = np.ogrid[float(-filter_n):float(filter_n+1),float(-filter_n):float(filter_n+1)]
    sum = 0
    for i in range(size):
        for j in range(size):
            e = mt.exp((-((x[0][j]**2)+(y[i][0]**2))/(2*(sigma**2))))
            filter[i][j] = e*(1/(2*mt.pi*(sigma**2)))
            sum = sum + filter[i][j]
    for i in range(size):
        for j in range(size):
            filter[i][j] = filter[i][j]/sum
    #r, c = og_im.shape
    m_im = resize_image(og_im, size)
    m_r, m_c = m_im.shape
    op_im = convolution(m_im, filter)
    return op_im

'''To obtain the X-derivative'''
def grad_x(ip_im):
    filter_x = [[-1,0,+1], [-1,0,+1], [-1,0,+1]]
    filter_x = np.array(filter_x)
    m_im = resize_image(ip_im, 3)
    op_im = convolution(m_im, filter_x)
    return op_im

'''To obtain the Y-derivative'''
def grad_y(ip_im):
    filter_y = [[-1,-1,-1], [0,0,0], [+1,+1,+1]]
    filter_y = np.array(filter_y)
    m_im = resize_image(ip_im, 3)
    op_im = convolution(m_im, filter_y)
    return op_im

'''To calculate the moment matrix for each pixel'''
def calc_moment_matrix(ip_im):
    im_ar = np.asarray(ip_im)
    im_x_ar = grad_x(im_ar)
    im_y_ar = grad_y(im_ar)
    r, c = im_x_ar.shape
    im_xx_ar = np.zeros((r, c))
    im_yy_ar = np.zeros((r, c))
    im_xy_ar = np.zeros((r, c))
    for i in range(r):
        for j in range(c):
            im_xx_ar[i][j] = im_x_ar[i][j]*im_x_ar[i][j]
            im_yy_ar[i][j] = im_y_ar[i][j]*im_y_ar[i][j]
            im_xy_ar[i][j] = im_x_ar[i][j]*im_y_ar[i][j]
    im_xxg_ar = gauss_filter(im_xx_ar, 5, 1)
    im_yyg_ar = gauss_filter(im_yy_ar, 5, 1)
    im_xyg_ar = gauss_filter(im_xy_ar, 5, 1)
    mm = [[[] for i in range(c)] for j in range(r)]
    for i in range(r):
        for j in range(c):
            mm[i][j] = [im_xxg_ar[i][j], im_xyg_ar[i][j], im_yyg_ar[i][j]]
    return mm

'''To calculate the response value for each pixel'''
def corner_response(ip_im, mm, k, t):
    im_ar = np.asarray(ip_im)
    r, c = im_ar.shape
    res = np.zeros((r, c))
    no_c = 0
    corners = []
    for i in range(r):
        for j in range(c):
            res[i][j] = ((mm[i][j][0]*mm[i][j][2]) - (mm[i][j][1]**2)) - (k*((mm[i][j][0]+mm[i][j][2])**2))
    res = resize_image(res, 3)
    rn, cn = res.shape
    for i in range(1, rn-1):
        for j in range(1, cn-1):
            if(res[i][j] > t):
                if(res[i][j] == max(res[i-1][j-1], res[i-1][j], res[i-1][j+1], res[i][j-1], res[i][j], res[i][j+1], res[i+1][j-1], res[i+1][j], res[i+1][j+1])):
                    corners.append([i-1, j-1, res[i-1][j-1]])
                    no_c = no_c + 1
    return corners

'''To calculate the SAD distance to obtain the various correspondences'''
def calc_sad(im_tr, im_tl, trc, tlc):
    im_tr = np.asarray(im_tr)
    im_tl = np.asarray(im_tl)
    r, c = im_tr.shape
    dist = []
    for left in tlc:
        for right in trc:
            s = 0
            for i in range(-1, 2):
                li = i + left[0]
                ri = i + right[0]
                for j in range(-1, 2):
                    lj = j + left[1]
                    rj = j + right[1]
                    if(0<=li<r and 0<=lj<c and 0<=ri<r and 0<=rj<c):
                        s = s + abs(int(im_tl[li][lj]) - int(im_tr[ri][rj]))
            dist.append([s, [left[0], left[1]], [right[0], right[1]]])
    dist.sort()
    return dist

'''To report the accuracies for the various correspondences'''
def report(dist, disp):
    disp = np.asarray(disp)
    no_c = 0
    no_ic = 0
    pm = 5
    p = (pm/100)*len(dist)
    for corr in dist:
        i = corr[1][0]
        j = corr[1][1]
        og_dis = disp[i][j]
        c_dis = abs(corr[1][1] - corr[2][1])
        if(abs(og_dis-c_dis) < 2):
            no_c = no_c + 1
        else:
            no_ic = no_ic + 1
        total = no_c + no_ic
        p = int((pm/100)*len(dist))
        if(p == total):
            cor_p = (no_c/total)*100
            print("Percent: "+str(pm)+"; Correct: "+str(no_c)+"; Total: "+str(total)+"; Accuracy: "+str(cor_p))
            pm = pm + 5

'''The main function'''
def main():
    og_im_tr = Image.open('teddy/teddyR.pgm')
    og_im_tl = Image.open('teddy/teddyL.pgm')
    og_im_disp = Image.open('teddy/disp2.pgm')
    tr_mm = calc_moment_matrix(og_im_tr)
    tr_co = corner_response(og_im_tr, tr_mm, 0.05, 12000000)
    tl_mm = calc_moment_matrix(og_im_tl)
    tl_co = corner_response(og_im_tl, tl_mm, 0.05, 12000000)
    dist = calc_sad(og_im_tr, og_im_tl, tr_co, tl_co)
    report(dist, og_im_disp)

main()