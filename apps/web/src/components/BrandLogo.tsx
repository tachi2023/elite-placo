type BrandLogoProps = {
  className?: string;
  titleClassName?: string;
  subtitleClassName?: string;
};

export default function BrandLogo({
  className = '',
  titleClassName = '',
  subtitleClassName = '',
}: BrandLogoProps) {
  return (
    <span
      className={`inline-flex min-w-0 flex-col leading-none ${className}`}
      aria-label="Élite Placo & Déco, PAR PRIMA BTP"
    >
      <span
        className={`whitespace-nowrap font-display text-or-clair ${titleClassName}`}
      >
        Élite Placo <span className="text-or">&amp;</span> Déco
      </span>
      <span
        className={`mt-1 whitespace-nowrap font-sans text-[9px] uppercase tracking-[0.28em] text-texte-muted ${subtitleClassName}`}
      >
        PAR PRIMA BTP
      </span>
    </span>
  );
}
