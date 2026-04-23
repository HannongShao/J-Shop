const PRODUCT_GALLERY_SELECTORS = {
  galleryRoot: "[data-product-gallery]",
  featuredImage: "[data-product-featured-image]",
  thumbnail: "[data-product-thumb]"
};

function setActiveGalleryThumbnail(gallery, activeThumbnail) {
  gallery.querySelectorAll(PRODUCT_GALLERY_SELECTORS.thumbnail).forEach((thumbnail) => {
    const isActive = thumbnail === activeThumbnail;
    thumbnail.setAttribute("aria-current", String(isActive));
  });
}

function syncFeaturedImage(featuredImage, thumbnail) {
  const imageSource = thumbnail.getAttribute("data-image-src");
  const imageSourceSet = thumbnail.getAttribute("data-image-srcset");
  const imageAlt = thumbnail.getAttribute("data-image-alt") || "";

  if (!imageSource) {
    return;
  }

  featuredImage.setAttribute("src", imageSource);

  if (imageSourceSet) {
    featuredImage.setAttribute("srcset", imageSourceSet);
  } else {
    featuredImage.removeAttribute("srcset");
  }

  featuredImage.setAttribute("alt", imageAlt);
}

function initProductGallery(gallery) {
  const featuredImage = gallery.querySelector(PRODUCT_GALLERY_SELECTORS.featuredImage);
  const thumbnails = Array.from(gallery.querySelectorAll(PRODUCT_GALLERY_SELECTORS.thumbnail));

  if (!featuredImage || !thumbnails.length) {
    return;
  }

  thumbnails.forEach((thumbnail) => {
    thumbnail.addEventListener("click", () => {
      syncFeaturedImage(featuredImage, thumbnail);
      setActiveGalleryThumbnail(gallery, thumbnail);
    });
  });
}

document.querySelectorAll(PRODUCT_GALLERY_SELECTORS.galleryRoot).forEach(initProductGallery);
