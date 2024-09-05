import cv2
import math
import numpy as np
import torch
from scipy import special
from scipy.stats import multivariate_normal
from torchvision.transforms.functional import rgb_to_grayscale

# Utility functions
def sigma_matrix2(sig_x, sig_y, theta):
    d_matrix = np.array([[sig_x**2, 0], [0, sig_y**2]])
    u_matrix = np.array([[np.cos(theta), -np.sin(theta)], [np.sin(theta), np.cos(theta)]])
    return np.dot(u_matrix, np.dot(d_matrix, u_matrix.T))

def mesh_grid(kernel_size):
    ax = np.arange(-kernel_size // 2 + 1., kernel_size // 2 + 1.)
    xx, yy = np.meshgrid(ax, ax)
    xy = np.stack([xx, yy], axis=-1)
    return xy, xx, yy

def pdf2(sigma_matrix, grid):
    inv_sigma = np.linalg.inv(sigma_matrix)
    kernel = np.exp(-0.5 * np.einsum('...i,ij,...j', grid, inv_sigma, grid))
    return kernel / kernel.sum()

def bivariate_kernel(kernel_size, sig_x, sig_y=None, theta=0, grid=None, kernel_func=pdf2):
    grid, _, _ = mesh_grid(kernel_size) if grid is None else grid
    sigma_matrix = sigma_matrix2(sig_x, sig_y or sig_x, theta)
    return kernel_func(sigma_matrix, grid)

def random_bivariate_kernel(kernel_size, sig_x_range, sig_y_range, rotation_range, noise_range=None, isotropic=True):
    sig_x = np.random.uniform(*sig_x_range)
    sig_y, rotation = (sig_x, 0) if isotropic else (np.random.uniform(*sig_y_range), np.random.uniform(*rotation_range))
    kernel = bivariate_kernel(kernel_size, sig_x, sig_y, rotation)
    if noise_range:
        noise = np.random.uniform(*noise_range, kernel.shape)
        kernel *= noise
    return kernel / kernel.sum()

# Gaussian noise
def generate_gaussian_noise(img, sigma=10, gray_noise=False):
    noise = np.random.randn(*img.shape[:2]) * sigma / 255.
    return np.repeat(noise[:, :, None], 3, axis=2) if gray_noise else noise

def add_gaussian_noise(img, sigma=10, clip=True, gray_noise=False):
    noise = generate_gaussian_noise(img, sigma, gray_noise)
    noisy_img = np.clip(img + noise, 0, 1) if clip else img + noise
    return noisy_img

# Poisson noise
def generate_poisson_noise(img, scale=1.0, gray_noise=False):
    img = np.clip(np.round(img * 255), 0, 255) / 255.
    vals = 2**np.ceil(np.log2(len(np.unique(img))))
    noise = np.random.poisson(img * vals) / vals - img
    return np.repeat(noise[:, :, None], 3, axis=2) * scale if gray_noise else noise * scale

def add_poisson_noise(img, scale=1.0, clip=True, gray_noise=False):
    noise = generate_poisson_noise(img, scale, gray_noise)
    noisy_img = np.clip(img + noise, 0, 1) if clip else img + noise
    return noisy_img

# JPEG Compression
def add_jpg_compression(img, quality=90):
    img = np.clip(img, 0, 1)
    encimg = cv2.imencode('.jpg', (img * 255).astype(np.uint8), [int(cv2.IMWRITE_JPEG_QUALITY), quality])[1]
    return cv2.imdecode(encimg, 1).astype(np.float32) / 255.

# Random compression
def random_add_jpg_compression(img, quality_range=(90, 100)):
    quality = np.random.uniform(*quality_range)
    return add_jpg_compression(img, quality)
