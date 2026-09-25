import React from 'react';

export default function ShinyText({
  text,
  disabled = false,
  speed = 5,
  className = ''
}) {
  const animationDuration = `${speed}s`;

  return (
    <span
      className={`inline-block bg-clip-text text-transparent bg-linear-to-r from-[#002B49] via-emerald-600 to-[#002B49] bg-size-[200%_100%] ${
        disabled ? '' : 'animate-shiny-text'
      } ${className}`}
      style={{
        animationDuration,
        backgroundImage: 'linear-gradient(120deg, #002B49 0%, #005E99 25%, #059669 50%, #005E99 75%, #002B49 100%)',
        backgroundSize: '200% 100%',
        WebkitBackgroundClip: 'text',
        WebkitTextFillColor: 'transparent'
      }}
    >
      {text}
    </span>
  );
}
