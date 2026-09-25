import React, { useEffect, useRef, useState } from 'react';

export default function ScrollReveal({
  children,
  animation = 'zoom-bounce',
  delay = 0,
  duration = 750,
  threshold = 0.12,
  className = ''
}) {
  const [isVisible, setIsVisible] = useState(false);
  const domRef = useRef(null);

  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            setIsVisible(true);
            observer.unobserve(entry.target);
          }
        });
      },
      { threshold }
    );

    const currentTarget = domRef.current;
    if (currentTarget) {
      observer.observe(currentTarget);
    }

    return () => {
      if (currentTarget) {
        observer.unobserve(currentTarget);
      }
    };
  }, [threshold]);

  const getAnimationStyles = () => {
    let initialTransform = 'translateY(45px) scale(0.92)';
    let initialOpacity = 0;
    let timingFunction = 'cubic-bezier(0.175, 0.885, 0.32, 1.275)'; // Custom spring bounce curve!

    if (animation === 'zoom-bounce') {
      initialTransform = 'translateY(50px) scale(0.88) rotateX(10deg)';
      timingFunction = 'cubic-bezier(0.34, 1.56, 0.64, 1)';
    } else if (animation === 'flip-in') {
      initialTransform = 'perspective(1000px) rotateX(25deg) translateY(40px)';
      timingFunction = 'cubic-bezier(0.16, 1, 0.3, 1)';
    } else if (animation === 'slide-left') {
      initialTransform = 'translateX(-60px) scale(0.95)';
      timingFunction = 'cubic-bezier(0.16, 1, 0.3, 1)';
    } else if (animation === 'slide-right') {
      initialTransform = 'translateX(60px) scale(0.95)';
      timingFunction = 'cubic-bezier(0.16, 1, 0.3, 1)';
    } else if (animation === 'fade-up') {
      initialTransform = 'translateY(40px) scale(0.96)';
      timingFunction = 'cubic-bezier(0.16, 1, 0.3, 1)';
    }

    return {
      opacity: isVisible ? 1 : initialOpacity,
      transform: isVisible ? 'translateY(0) translateX(0) scale(1) rotateX(0deg)' : initialTransform,
      transition: `opacity ${duration}ms cubic-bezier(0.16, 1, 0.3, 1) ${delay}ms, transform ${duration}ms ${timingFunction} ${delay}ms`,
      willChange: 'opacity, transform',
      perspective: '1000px'
    };
  };

  return (
    <div ref={domRef} style={getAnimationStyles()} className={className}>
      {children}
    </div>
  );
}
